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

/// Something that can provide an authorization header for authentication and authorization.
protocol ApiAuthorizing {
    /// Name of the authorization header field. Defaults to HTTP's "Authorization".
    var autorizationHeaderField: String { get }

    /// Provides the authorization header value for the request given.
    ///
    /// - Remark: This method should be invoked after the request is fully configured as it may depend on other parameters.
    func authorizationHeader(for request: URLRequest) -> String

    /// Whether the client is authorized to use the API. May return `false` e.g. if the authorizer is in an initialization
    /// phase.
    var isAuthorized: Bool { get }
}

extension ApiAuthorizing {
    var autorizationHeaderField: String {
        return "Authorization"
    }
}
