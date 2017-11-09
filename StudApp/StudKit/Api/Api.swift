//
//  Api.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

class Api<Routes: ApiRoutes> {
    private let defaultPort = 443
    private let session: URLSession
    private let baseUrl: URL

    init(baseUrl: URL, session: URLSession = URLSession(configuration: .default)) {
        self.baseUrl = baseUrl
        self.session = session
    }
    
    var protectionSpace: URLProtectionSpace {
        guard let host = baseUrl.host, let scheme = baseUrl.scheme else {
            fatalError("Cannot get host or scheme from base URL '\(baseUrl)'.")
        }
        return URLProtectionSpace(host: host, port: baseUrl.port ?? defaultPort, protocol: scheme,
                                  realm: nil, authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
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

    @discardableResult
    func request(_ route: Routes, parameters: [URLQueryItem] = [], queue: DispatchQueue = .main,
                 handler: @escaping ResultHandler<Data>) -> Progress {
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
        return task.progress
    }
}

extension Api {
    @discardableResult
    func download(_ route: Routes, parameters: [URLQueryItem] = [], queue: DispatchQueue = .main,
                  handler: @escaping ResultHandler<URL>) -> Progress {
        guard let url = self.url(for: route, parameters: parameters) else {
            fatalError("Cannot construct URL for route '\(route)'.")
        }
        let request = self.request(for: url, method: route.method)
        let task = session.downloadTask(with: request) { url, response, error in
            let response = response as? HTTPURLResponse
            let result = Result(url, error: error, statusCode: response?.statusCode)
            queue.async {
                handler(result)
            }
        }
        task.resume()
        return task.progress
    }
    
    @discardableResult
    func download(_ route: Routes, to destination: URL, parameters: [URLQueryItem] = [],
                  queue: DispatchQueue = .main, handler: @escaping ResultHandler<URL>) -> Progress {
        return download(route, parameters: parameters, queue: queue) { result in
            guard let url = result.value else { return handler(result) }
            do {
                let fileManager = FileManager.default
                try FileManager.default.createIntermediateDirectories(forFileAt: destination)
                try fileManager.moveItem(at: url, to: destination)
                handler(result.replacingValue(destination))
            } catch {
                handler(.failure(error))
            }
        }
    }
}

extension Api {
    @discardableResult
    func requestDecoded<Result: Decodable>(_ route: Routes, parameters: [URLQueryItem] = [],
                                           queue: DispatchQueue = .main, handler: @escaping ResultHandler<Result>) -> Progress {
        guard let type = route.type as? Result.Type else {
            fatalError("Trying to decode response from untyped API route '\(route)'.")
        }
        return request(route, parameters: parameters, queue: queue) { result in
            handler(result.decoded(type))
        }
    }
}
