//
//  UserResponseTests+Data.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 07.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
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
