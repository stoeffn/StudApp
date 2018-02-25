//
//  ApiRoute.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Represents an API route, usually being an enumeration.
protocol ApiRoutes: Hashable {
    /// Identifier unique to this route but not to its parameters. A route the returns a file with an id might have an
    /// identifier like "files/:fileId" where ":fileId" would normally be interpolated with the file's id.
    var identifier: String { get }

    /// Route's path that will be appended to an API's base `URL`.
    var path: String { get }

    /// If the route's return value conforms to `Decodable` the type can be specified here. This adds support for
    /// `API.requestDecoded`, which returns the server's response as a decoded object. Defaults to `nil`.
    var type: Decodable.Type? { get }

    /// HTTP method this route should use. Defaults to `.get`.
    var method: HttpMethods { get }

    /// HTTP body. Defaults to `nil`.
    var body: Data? { get }

    /// `API` will not repeat requests to the same route before the last request time to the route plus its expiration time
    /// interval. Thus, unnecassary round-trips and data usage can be saved. Defaults to `0`.
    var expiresAfter: TimeInterval { get }
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

    var method: HttpMethods {
        return .get
    }

    var body: Data? {
        return nil
    }

    var expiresAfter: TimeInterval {
        return 0
    }
}
