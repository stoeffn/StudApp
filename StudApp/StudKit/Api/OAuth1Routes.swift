//
//  OAuth1Routes.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

protocol OAuth1Routes: ApiRoutes {
    static var requestToken: Self { get }
}
