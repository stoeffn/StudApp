//
//  ApiCredentials.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Credentials for logging into an API.
struct ApiCredentials {
    let username: String
    let password: String

    /// HTTP Basic Authorization Header value based on the username and password.
    var authorizationValue: String {
        guard let userPasswordData = "\(username):\(password)".data(using: .utf8) else {
            fatalError("Failed to construct authentication credentials.")
        }
        return "Basic \(userPasswordData.base64EncodedString())"
    }
}
