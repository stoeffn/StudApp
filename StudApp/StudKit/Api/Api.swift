//
//  Api.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

class Api<Routes: ApiRoutes> {
    private let defaultPort = 443
    private let baseUrl: URL
    private let realm: String?
    private let session: URLSession
    private let authenticationMethod: String?

    init(baseUrl: URL, realm: String? = nil, session: URLSession = .shared,
         authenticationMethod: String = NSURLAuthenticationMethodHTTPBasic) {
        self.baseUrl = baseUrl
        self.realm = realm
        self.session = session
        self.authenticationMethod = authenticationMethod
    }

    var protectionSpace: URLProtectionSpace {
        guard let host = baseUrl.host, let scheme = baseUrl.scheme else {
            fatalError("Cannot get host or scheme from base URL '\(baseUrl)'.")
        }
        return URLProtectionSpace(host: host, port: baseUrl.port ?? defaultPort, protocol: scheme,
                                  realm: realm, authenticationMethod: authenticationMethod)
    }

    func url(for route: Routes, parameters: [URLQueryItem] = []) -> URL? {
        let url = baseUrl.appendingPathComponent(route.path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters
        return components?.url
    }

    func request(for url: URL, method: HttpMethod) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
}

// MARK: - Making Data Requests

extension Api {
    @discardableResult
    func request(_ route: Routes, parameters: [URLQueryItem] = [], queue: DispatchQueue = .main,
                 handler: @escaping ResultHandler<Data>) -> URLSessionTask {
        guard let url = self.url(for: route, parameters: parameters) else {
            fatalError("Cannot construct URL for route '\(route)'.")
        }
        let request = self.request(for: url, method: route.method)
        let task = session.dataTask(with: request) { data, response, error in
            let response = response as? HTTPURLResponse
            let result = Result(data, error: error, statusCode: response?.statusCode)

            queue.async {
                handler(result)
            }
        }
        task.resume()
        return task
    }
}

// MARK: - Decoding Data

extension Api {
    @discardableResult
    func requestDecoded<Result: Decodable>(_ route: Routes, parameters: [URLQueryItem] = [],
                                           queue: DispatchQueue = .main,
                                           handler: @escaping ResultHandler<Result>) -> URLSessionTask {
        guard let type = route.type as? Result.Type else {
            fatalError("Trying to decode response from untyped API route '\(route)'.")
        }
        return request(route, parameters: parameters, queue: queue) { result in
            handler(result.decoded(type))
        }
    }
}

// MARK: - Downloading

extension Api {
    @discardableResult
    func download(_ route: Routes, parameters: [URLQueryItem] = [], handler: @escaping ResultHandler<URL>) -> URLSessionTask {
        guard let url = self.url(for: route, parameters: parameters) else {
            fatalError("Cannot construct URL for route '\(route)'.")
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

    @discardableResult
    func download(_ route: Routes, to destination: URL, parameters: [URLQueryItem] = [],
                  queue: DispatchQueue = .main, handler: @escaping ResultHandler<URL>) -> URLSessionTask {
        return download(route, parameters: parameters) { result in
            guard let url = result.value else { return handler(result) }
            do {
                try FileManager.default.createIntermediateDirectories(forFileAt: destination)
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
