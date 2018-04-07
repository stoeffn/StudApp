//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

/// Represents an API route, usually being an enumeration.
protocol ApiRoutes {
    /// Identifier unique to this route but not to its parameters. A route the returns a file with an id might have an
    /// identifier like "files/:fileId" where ":fileId" would normally be interpolated with the file's id.
    var identifier: String { get }

    /// Route's path that will be appended to an API's base `URL`.
    var path: String { get }

    /// This property overrides the default URL creation. Defaults to `nil`.
    var url: URL? { get }

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
    var url: URL? {
        return nil
    }

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
