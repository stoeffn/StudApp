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

@testable import StudKit

extension UserResponseTests {
    static let user0Data = """
        {
            "id": "U0",
            "avatar_normal": "https:\\/\\/stud.ip\\/pictures\\/user\\/U0?d=1440683948",
            "name": {
                "username": "username",
                "formatted": "Formatted Name",
                "family": "Last Name",
                "given": "First Name",
                "prefix": "Prefix",
                "suffix": "Suffix"
            }
        }
    """.data(using: .utf8)!

    static let user1Data = """
        {
            "id": "U1",
            "avatar_normal": "https:\\/\\/stud.ip\\/pictures\\/user\\/nobody_normal.png?d=1440683948",
            "name": {
                "username": "username",
                "formatted": "Formatted Name",
                "family": "Last Name",
                "given": "First Name",
                "prefix": "",
                "suffix": ""
            }
        }
    """.data(using: .utf8)!

    static let user0 = UserResponse(id: "U0", username: "username", givenName: "First Name", familyName: "Last Name",
                                    namePrefix: "Prefix", nameSuffix: "Suffix")
}
