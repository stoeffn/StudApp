//
//  Api.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

class Api<Routes: ApiRoutes> {
    let baseUrl: URL
    let session: URLSession

    init(baseUrl: URL, session: URLSession = URLSession()) {
        self.baseUrl = baseUrl
        self.session = session
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
    func request(_ route: Routes, parameters: [URLQueryItem] = [], completionHandler: @escaping ResultCallback<Data>) -> Progress {
        guard let url = self.url(for: route, parameters: parameters) else {
            fatalError("Cannot construct URL for route '\(route)'.")
        }
        let request = self.request(for: url, method: route.method)
        let task = session.dataTask(with: request) { data, response, error in
            let response = response as? HTTPURLResponse
            let result = Result(data, error: error, statusCode: response?.statusCode)
            completionHandler(result)
        }
        task.resume()
        return task.progress
    }
}
