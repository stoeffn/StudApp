//
//  ApiRoute.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

protocol ApiRoutes: Hashable {
    var path: String { get }

    var type: Decodable.Type? { get }

    var method: HttpMethod { get }

    var expiresAfter: TimeInterval? { get }
}

// MARK: - Equatable Conformance

extension ApiRoutes {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.path == rhs.path
    }
}

// MARK: - Hashable Conformance

extension ApiRoutes {
    public var hashValue: Int {
        return path.hashValue
    }
}

// MARK: - Default Implementation

extension ApiRoutes {
    var type: Decodable.Type? {
        return nil
    }

    var method: HttpMethod {
        return .get
    }

    var expiresAfter: TimeInterval? {
        return nil
    }
}
