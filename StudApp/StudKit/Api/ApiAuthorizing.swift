//
//  ApiAuthorizing.swift
//  StudKit
//
//  Created by Steffen Ryll on 02.01.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

/// Something that can provide an authorization header for authentication and authorization.
protocol ApiAuthorizing {
    /// Name of the authorization header field. Defaults to HTTP's "Authorization".
    var autorizationHeaderField: String { get }

    /// Provides the authorization header value for the request given.
    ///
    /// - Remark: This method should be invoked after the request is fully configured as it may depend on other parameters.
    func authorizationHeader(for request: URLRequest) -> String
}

extension ApiAuthorizing {
    var autorizationHeaderField: String {
        return "Authorization"
    }
}
