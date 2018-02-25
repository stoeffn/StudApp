//
//  OAuth1Routes.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Routes needed for OAuth1 authorization.
protocol OAuth1Routes: ApiRoutes {
    /// Creates a request token that can be used for asking a user to grant access to a protected resource.
    static var requestToken: Self { get }

    /// Renders a web page where a user can grant the apllication access to protected resources.
    static var authorize: Self { get }

    /// Exchanges the temporary request token for a long-lived access token that can be used for accessing protected resources.
    static var accessToken: Self { get }
}

// MARK: - Default Implementation

extension OAuth1Routes {
    var identifier: String {
        return path
    }
}
