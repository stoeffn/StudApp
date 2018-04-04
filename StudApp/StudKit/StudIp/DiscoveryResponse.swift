//
//  DiscoveryResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 25.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

typealias DiscoveryResponse = [String: [String: String?]]

extension ApiRoutesAvailablity {
    init(from discovery: DiscoveryResponse) {
        routes = discovery.mapValues { methods in
            Set(methods.keys.compactMap { HttpMethods(rawValue: $0.uppercased()) })
        }
    }
}
