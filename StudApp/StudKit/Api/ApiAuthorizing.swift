//
//  ApiAuthorizing.swift
//  StudKit
//
//  Created by Steffen Ryll on 02.01.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

protocol ApiAuthorizing {
    var autorizationHeaderField: String { get }

    func authorizationHeader(for request: URLRequest) -> String
}

extension ApiAuthorizing {
    var autorizationHeaderField: String {
        return "Authorization"
    }
}
