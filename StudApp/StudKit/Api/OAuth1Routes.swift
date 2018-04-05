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

/// Routes needed for OAuth1 authorization.
protocol OAuth1Routes: ApiRoutes {
    /// Creates a request token that can be used for asking a user to grant access to a protected resource.
    static var requestToken: Self { get }

    /// Renders a web page where a user can grant the apllication access to protected resources.
    static var authorize: Self { get }

    /// Exchanges the temporary request token for a long-lived access token that can be used for accessing protected resources.
    static var accessToken: Self { get }
}

// MARK: - Default Implementation

extension OAuth1Routes {
    var identifier: String {
        return path
    }
}
