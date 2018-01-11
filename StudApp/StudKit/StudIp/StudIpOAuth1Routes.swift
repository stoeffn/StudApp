//
//  StudIpOAuth1Routes.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

struct StudIpOAuth1Routes: OAuth1Routes {
    static let requestToken = StudIpOAuth1Routes(path: "request_token")

    static var authorize = StudIpOAuth1Routes(path: "authorize")

    static var accessToken = StudIpOAuth1Routes(path: "access_token")

    let path: String
}
