//
//  ApiRoute.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Represents an API route, usually being an enumeration.
protocol ApiRoutes {
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

    /// Mime type to send in the the HTTP request header. Defaults to `nil`.
    var contentType: String? { get }

    /// HTTP body. Defaults to `nil`.
    var body: Data? { get }
}

// MARK: - Default Implementation

extension ApiRoutes {
    var type: Decodable.Type? {
        return nil
    }

    var method: HttpMethods {
        return .get
    }

    var contentType: String? {
        return nil
    }

    var body: Data? {
        return nil
    }
}
