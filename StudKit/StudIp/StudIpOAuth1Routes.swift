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

struct StudIpOAuth1Routes: OAuth1Routes {
    static let requestToken = StudIpOAuth1Routes(path: "../dispatch.php/api/oauth/request_token", method: .post)

    static var authorize = StudIpOAuth1Routes(path: "../dispatch.php/api/oauth/authorize", method: .get)

    static var accessToken = StudIpOAuth1Routes(path: "../dispatch.php/api/oauth/access_token", method: .post)

    let path: String

    let method: HttpMethods
}
