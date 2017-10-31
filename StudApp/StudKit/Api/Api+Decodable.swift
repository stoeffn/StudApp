//
//  Api+Decodable.swift
//  StudKit
//
//  Created by Steffen Ryll on 29.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

extension Api {
    @discardableResult
    func requestDecoded<Result: Decodable>(_ route: Routes, parameters: [URLQueryItem] = [],
                                           completionHandler: @escaping ResultCallback<Result>) -> Progress {
        guard let type = route.type as? Result.Type else {
            fatalError("Trying to decode response from untyped API route '\(route)'.")
        }
        return request(route, parameters: parameters) { result in
            completionHandler(result.decoded(type))
        }
    }
}
