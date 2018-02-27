//
//  Api.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Wrapper around `URLSession` that allows simple and easy access to an API.
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
/// You can also set `authorizing`, which is then used in order to authenticate and authorize against the API.
///
/// Depending on the `URLSession` given on initialization, this class uses the default `URLCredentialStorage`.
///
/// - Remark: This class is not marked `final` in order to allow subclassing for mock implementations. Usually, you will not
///           need to subclass it.
class Api<Routes: ApiRoutes> {

    // MARK: - Errors

    /// Custom errors that may occur additionally to error returned by `URLSession`.
    enum Errors: Error {
        /// A request cannot be created due to a missing base URL. Set `baseUrl` on this object in order to solve this problem.
        case missingBaseUrl

        /// Route was recently accessed and has not expired yet. Set `ignoreLastAccess` to `true` when issuing requests if you
        /// want to force an API request to this route.
        case routeNotExpired
    }

    // MARK: - Life Cycle

    private let session: URLSession
    private var lastRouteAccesses = [Routes: Date]()

    /// Base `URL` of all requests this instance issues. Any route paths will be appended to it.
    var baseUrl: URL?

    /// Something that can provide an authorization header for authentication and authorization.
    var authorizing: ApiAuthorizing?

    /// Creates a new API wrapper at `baseUrl`.
    ///
    /// - Parameters:
    ///   - baseUrl: Base `URL` of all requests this instance issues. Any route paths will be appended to it.
    ///   - authorizing: Something that can authorize the client to access the API by providing an authorization header.
    ///   - session: URL Session, which defaults to the shared session.
    init(baseUrl: URL? = nil, authorizing: ApiAuthorizing? = nil, session: URLSession = .shared) {
        self.baseUrl = baseUrl
        self.authorizing = authorizing
        self.session = session
    }

    // MARK: - Creating Requests

    /// Returns the full `URL` for `route`, consisting of the base `URL` as well as the route's path and query parameters.
    func url(for route: Routes, parameters: [URLQueryItem] = []) throws -> URL {
        guard let url = baseUrl?.appendingPathComponent(route.path) else { throw Errors.missingBaseUrl }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters

        guard let urlWithParameters = components?.url else {
            fatalError("Cannot construct URL with query parameters for route '\(route)'.")
        }
        return urlWithParameters
    }

    /// Returns a request for the `URL` given and an HTTP method. Optionally, you can add body data and a content type.
    func request(for url: URL, method: HttpMethods, body: Data? = nil, contentType: String? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        if let contentType = contentType {
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        if let authorizing = authorizing {
            request.addValue(authorizing.authorizationHeader(for: request), forHTTPHeaderField: authorizing.autorizationHeaderField)
        }

        return request
    }

    // MARK: - Managing Expiry

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
    /// - Remark: For example, this is useful when signing out because all data should be reloaded when signing back in.
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
    ///   - completion: Completion handler receiving a result with the raw data.
    /// - Returns: URL task in its resumed state or `nil` if the route is not expired or building the request failed.
    @discardableResult
    func request(_ route: Routes, parameters: [URLQueryItem] = [], ignoreLastAccess: Bool = false, queue: DispatchQueue = .main,
                 completion: @escaping ResultHandler<Data>) -> URLSessionTask? {
        guard ignoreLastAccess || isRouteExpired(route) else {
            completion(.failure(Errors.routeNotExpired))
            return nil
        }

        do {
            let url = try self.url(for: route, parameters: parameters)
            let request = self.request(for: url, method: route.method, body: route.body, contentType: route.contentType)
            let task = session.dataTask(with: request) { data, response, error in
                let response = response as? HTTPURLResponse
                let result = Result(data, error: error, statusCode: response?.statusCode)

                if result.isSuccess {
                    self.setRouteAccessed(route)
                }

                queue.async {
                    completion(result)
                }
            }
            task.resume()
            return task
        } catch {
            completion(.failure(error))
            return nil
        }
    }

    // MARK: - Decoding Data

    /// Requests data from this API and decodes as the type defined by the route.
    ///
    /// - Parameters:
    ///   - route: Route to request data from.
    ///   - parameters: Optional query parameters.
    ///   - ignoreLastAccess: Whether to ignore the route's expiry policy. Defaults to `false`.
    ///   - queue: Dispatch queue to execute the completion handler on. Defaults to the main queue.
    ///   - completion: Completion handler receiving a result with the decoded object.
    /// - Returns: URL task in its resumed state or `nil` if the route is not expired.
    /// - Precondition: `route`'s type must not be `nil`.
    /// - Remark: At the moment, this method supports JSON decoding only.
    @discardableResult
    func requestDecoded<Result: Decodable>(_ route: Routes, parameters: [URLQueryItem] = [], ignoreLastAccess: Bool = false,
                                           queue: DispatchQueue = .main,
                                           completion: @escaping ResultHandler<Result>) -> URLSessionTask? {
        guard let type = route.type as? Result.Type else {
            fatalError("Trying to decode response from untyped API route '\(route)'.")
        }
        return request(route, parameters: parameters, ignoreLastAccess: ignoreLastAccess, queue: queue) { result in
            completion(result.decoded(type))
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
    ///   - startsResumed: Whether the URL task returned starts in its resumed state.
    ///   - completion: Completion handler a URL pointing to the dowloaded file.
    /// - Returns: URL task in its resumed state or `nil` if building the request failed.
    /// - Remark: There is no `queue` parameter on this method because the file must be read or moved synchronously. This
    ///           method does not check or set last access times.
    @discardableResult
    func download(_ route: Routes, parameters: [URLQueryItem] = [], startsResumed: Bool = true,
                  completion: @escaping ResultHandler<URL>) -> URLSessionTask? {
        do {
            let url = try self.url(for: route, parameters: parameters)
            let request = self.request(for: url, method: route.method)
            let task = session.downloadTask(with: request) { url, response, error in
                let response = response as? HTTPURLResponse
                let result = Result(url, error: error, statusCode: response?.statusCode)
                completion(result)
            }

            if startsResumed {
                task.resume()
            }

            return task
        } catch {
            completion(.failure(nil))
            return nil
        }
    }

    /// Downloads data from this API to disk and moves it to `destination`.
    ///
    /// - Parameters:
    ///   - route: Route to request data from.
    ///   - destination: Destination `URL` to move the file to after the download completes successfully.
    ///   - parameters: Optional query parameters.
    ///   - startsResumed: Whether the URL task returned starts in its resumed state.
    ///   - queue: Dispatch queue to execute the completion handler on. Defaults to the main queue.
    ///   - completion: Completion handler receiving a result with an URL pointing to the dowloaded file.
    /// - Returns: URL task in its resumed state or `nil` if building the request failed.
    /// - Remark: The downloaded document overrides any existing file at `destination`.
    @discardableResult
    func download(_ route: Routes, to destination: URL, parameters: [URLQueryItem] = [], startsResumed: Bool = true,
                  queue: DispatchQueue = .main, completion: @escaping ResultHandler<URL>) -> URLSessionTask? {
        return download(route, parameters: parameters, startsResumed: startsResumed) { result in
            let result = result.map { url -> URL in
                try FileManager.default.createIntermediateDirectories(forFileAt: destination)
                try? FileManager.default.removeItem(at: destination)
                try FileManager.default.moveItem(at: url, to: destination)
                return destination
            }
            queue.async {
                completion(result)
            }
        }
    }
}
