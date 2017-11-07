//
//  Api+Download.swift
//  StudKit
//
//  Created by Steffen Ryll on 29.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

extension Api {
    @discardableResult
    func download(_ route: Routes, parameters: [URLQueryItem] = [], queue: DispatchQueue = DispatchQueue.main,
                  completionHandler: @escaping ResultCallback<URL>) -> Progress {
        guard let url = self.url(for: route, parameters: parameters) else {
            fatalError("Cannot construct URL for route '\(route)'.")
        }
        let request = self.request(for: url, method: route.method)
        let task = session.downloadTask(with: request) { url, response, error in
            let response = response as? HTTPURLResponse
            let result = Result(url, error: error, statusCode: response?.statusCode)
            queue.async {
                completionHandler(result)
            }
        }
        task.resume()
        return task.progress
    }

    @discardableResult
    func download(_ route: Routes, to destination: URL, parameters: [URLQueryItem] = [],
                  queue: DispatchQueue = DispatchQueue.main, completionHandler: @escaping ResultCallback<URL>) -> Progress {
        return download(route, parameters: parameters, queue: queue) { result in
            guard let url = result.value else { return completionHandler(result) }
            do {
                let fileManager = FileManager.default
                try FileManager.default.createIntermediateDirectories(forFileAt: destination)
                try fileManager.moveItem(at: url, to: destination)
                completionHandler(result.replacingValue(destination))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
}
