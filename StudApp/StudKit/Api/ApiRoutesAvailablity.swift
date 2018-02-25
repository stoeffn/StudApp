//
//  ApiRoutesAvailablity.swift
//  StudKit
//
//  Created by Steffen Ryll on 25.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

struct ApiRoutesAvailablity: Codable {
    let routes: [String: Set<HttpMethods>]
}
