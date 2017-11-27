//
//  Api.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Wrapper around `URLSession` that allows simple and easy access to an online API.
///
/// To use it, just create your own type, peferably an enumeration, implementing `ApiRoutes` and initialize an instance of this
/// class with your routes and a base `URL`.
///
/// You can use this class to make API requests, decode them automatically, and download files.
///
/// `Api` also handles route expiry in order to protect against too many requests to one API route, thus reducing data usage. It
/// works by keeping track of routes' last access times and comparing them to the current time as well as the routes' expiry
/// policy. Please note that this information is local to one `Api` instance and not cached anywhere else.
///
/// Depending on the `URLSession` given on initialization, this class uses the default `URLCredentialStorage`.
///
/// - Remark: This class is not marked `final` in order to allow subclassing for mock implementations. Usually, you will not
///           need to subclass it.
class Api<Routes: ApiRoutes> {
    private let defaultPort = 443
    private let session: URLSession
    private let authenticationMethod: String?
    private var lastRouteAccesses = [Routes: Date]()

    /// Base `URL` of all requests this instance issues. Any route paths will be appended to it.
    ///
    /// - Warning: The application will crash when `nil` and trying to issue a request.
    var baseUrl: URL?

    /// When using authentication, sometimes you also need to specify a realm apart from just a username and password. This
    /// realm will be used for ceating this API's `protectionSpace`.
    var realm: String?

    /// Creates a new API wrapper at `baseUrl`.
    ///
    /// - Parameters:
    ///   - baseUrl: Base `URL` of all requests this instance issues. Any route paths will be appended to it.
    ///   - realm: When using authentication, sometimes you also need to specify a realm apart from just a username and
    ///            password. This realm will be used for ceating this API's `protectionSpace`.
    ///   - session: URL Session, which defaults to the shared session.
    ///   - authenticationMethod: URL Authentication Method, which default to HTTP Basic Authentication.
    init(baseUrl: URL? = nil, realm: String? = nil, session: URLSession = .shared,
         authenticationMethod: String = NSURLAuthenticationMethodHTTPBasic) {
        self.baseUrl = baseUrl
        self.realm = realm
        self.session = session
        self.authenticationMethod = authenticationMethod
    }

    /// This API's protection space, which is created using the base URL's components as well as the realm and URL
    /// Authentication Method given at initialization.
    ///
    /// - Remark: If the base URL does not include an explicit port, the default HTTPS port will be used.
    var protectionSpace: URLProtectionSpace? {
        guard let host = baseUrl?.host, let scheme = baseUrl?.scheme else { return nil }
        return URLProtectionSpace(host: host, port: baseUrl?.port ?? defaultPort, protocol: scheme,
                                  realm: realm, authenticationMethod: authenticationMethod)
    }

    /// Returns the full `URL` for `route`, consisting of the base `URL` as well as the route's path and query parameters.
    func url(for route: Routes, parameters: [URLQueryItem] = []) -> URL? {
        guard let url = baseUrl?.appendingPathComponent(route.path) else { return nil }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters

        guard let urlWithParamters = components?.url else {
            fatalError("Cannot construct URL with query parameters for route '\(route)'.")
        }
        return urlWithParamters
    }

    /// Returns a request for the `URL` given and an HTTP method.
    func request(for url: URL, method: HttpMethod) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }

    /// Returns whether a given route is expired. If a route has not been accessed before, this method returns `true`.
    /// Otherwise, it respects the route's expiry policy by comparing the last access time to the current time.
    func isRouteExpired(_ route: Routes) -> Bool {
        guard let lastAccess = lastRouteAccesses[route] else { return true }
        return lastAccess + route.expiresAfter < Date()
    }

    /// Mark a route as being accessed on the current time.
    func setRouteAccessed(_ route: Routes) {
        lastRouteAccesses[route] = Date()
    }

    /// Removes the last access date for `route`.
    func removeLastAccess(for route: Routes) {
        lastRouteAccesses.removeValue(forKey: route)
    }

    /// Clears all route access data.
    ///
    /// For example, this is useful when signing out because all data should be reloaded when signing back in.
    func removeLastRouteAccesses() {
        lastRouteAccesses.removeAll()
    }

    // MARK: - Making Data Requests

    /// Requests data from this API.
    ///
    /// - Parameters:
    ///   - route: Route to request data from.
    ///   - parameters: Optional query parameters.
    ///   - ignoreLastAccess: Whether to ignore the route's expiry policy. Defaults to `false`.
    ///   - queue: Dispatch queue to execute the completion handler on. Defaults to the main queue.
    ///   - handler: Completion handler receiving a result with the raw data.
    /// - Returns: URL task in its resumed state or `nil` if the route is not expired or building the request failed.
    @discardableResult
    func request(_ route: Routes, parameters: [URLQueryItem] = [], ignoreLastAccess: Bool = false, queue: DispatchQueue = .main,
                 handler: @escaping ResultHandler<Data>) -> URLSessionTask? {
        guard ignoreLastAccess || isRouteExpired(route), let url = self.url(for: route, parameters: parameters) else {
            handler(.failure(nil))
            return nil
        }

        let request = self.request(for: url, method: route.method)
        let task = session.dataTask(with: request) { data, response, error in
            let response = response as? HTTPURLResponse
            let result = Result(data, error: error, statusCode: response?.statusCode)

            if result.isSuccess {
                self.setRouteAccessed(route)
            }

            queue.async {
                handler(result)
            }
        }
        task.resume()
        return task
    }

    // MARK: - Decoding Data

    /// Requests data from this API and decodes as the type defined by the route.
    ///
    /// - Parameters:
    ///   - route: Route to request data from.
    ///   - parameters: Optional query parameters.
    ///   - ignoreLastAccess: Whether to ignore the route's expiry policy. Defaults to `false`.
    ///   - queue: Dispatch queue to execute the completion handler on. Defaults to the main queue.
    ///   - handler: Completion handler receiving a result with the decoded object.
    /// - Returns: URL task in its resumed state or `nil` if the route is not expired.
    /// - Precondition: `route`'s type must not be `nil`.
    /// - Remark: At the moment, this method supports JSON decoding only.
    @discardableResult
    func requestDecoded<Result: Decodable>(_ route: Routes, parameters: [URLQueryItem] = [], ignoreLastAccess: Bool = false,
                                           queue: DispatchQueue = .main,
                                           handler: @escaping ResultHandler<Result>) -> URLSessionTask? {
        guard let type = route.type as? Result.Type else {
            fatalError("Trying to decode response from untyped API route '\(route)'.")
        }
        return request(route, parameters: parameters, ignoreLastAccess: ignoreLastAccess, queue: queue) { result in
            handler(result.decoded(type))
        }
    }

    // MARK: - Downloading Data

    /// Downloads data from this API to disk.
    ///
    /// If the request completes successfully, the location parameter of the completion handler block contains the location of
    /// the temporary file, and the error parameter is `nil`. You must move the file or open it for reading before the
    /// completion handler returns. Otherwise, the downloaded file might be deleted.
    ///
    /// - Parameters:
    ///   - route: Route to request data from.
    ///   - parameters: Optional query parameters.
    ///   - handler: Completion handler a URL pointing to the dowloaded file.
    /// - Returns: URL task in its resumed state or `nil` if building the request failed.
    /// - Remark: There is no `queue` parameter on this method because the file must be read or moved synchronously.
    @discardableResult
    func download(_ route: Routes, parameters: [URLQueryItem] = [], handler: @escaping ResultHandler<URL>) -> URLSessionTask? {
        guard let url = self.url(for: route, parameters: parameters) else {
            handler(.failure(nil))
            return nil
        }

        let request = self.request(for: url, method: route.method)
        let task = session.downloadTask(with: request) { url, response, error in
            let response = response as? HTTPURLResponse
            let result = Result(url, error: error, statusCode: response?.statusCode)
            handler(result)
        }
        task.resume()
        return task
    }

    /// Downloads data from this API to disk and moves it to `destination`.
    ///
    /// - Parameters:
    ///   - route: Route to request data from.
    ///   - destination: Destination `URL` to move the file to after the download completes successfully.
    ///   - parameters: Optional query parameters.
    ///   - queue: Dispatch queue to execute the completion handler on. Defaults to the main queue.
    ///   - handler: Completion handler receiving a result with an URL pointing to the dowloaded file.
    /// - Returns: URL task in its resumed state or `nil` if building the request failed.
    /// - Remark: The downloaded document overrides any existing file at `destination`.
    @discardableResult
    func download(_ route: Routes, to destination: URL, parameters: [URLQueryItem] = [],
                  queue: DispatchQueue = .main, handler: @escaping ResultHandler<URL>) -> URLSessionTask? {
        return download(route, parameters: parameters) { result in
            guard let url = result.value, result.isSuccess else { return handler(result) }
            do {
                try FileManager.default.createIntermediateDirectories(forFileAt: destination)
                try? FileManager.default.removeItem(at: destination)
                try FileManager.default.moveItem(at: url, to: destination)

                queue.async {
                    handler(result.replacingValue(destination))
                }
            } catch {
                queue.async {
                    handler(.failure(error))
                }
            }
        }
    }
}
