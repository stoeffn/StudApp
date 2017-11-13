//
//  ApiRoute.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

protocol ApiRoutes {
    var path: String { get }

    var type: Decodable.Type? { get }

    var method: HttpMethod { get }
}

// MARK: - Default Implementation

extension ApiRoutes {
    var type: Decodable.Type? {
        return nil
    }

    var method: HttpMethod {
        return .get
    }
}
