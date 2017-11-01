//
//  UserModelTests+Data.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 07.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit

extension UserModelTests {
    static let user = UserModel(id: "0", username: "username", givenName: "First Name", familyName: "Last Name",
                                rawNamePrefix: "Prefix", rawNameSuffix: "Suffix")

    static let userData = """
        {
            "id": "e894bd27b2c3f5b25e438932f14b60e1",
            "avatar_normal": "https:\\/\\/studip.uni-hannover.de\\/pictures\\/user\\/a123c516de7c999f646c72c53ab38dc8_normal.png?d=1440683948",
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

    static let userWithoutPrefixAndPictureData = """
        {
            "id": "e894bd27b2c3f5b25e438932f14b60e1",
            "avatar_normal": "https:\\/\\/studip.uni-hannover.de\\/pictures\\/user\\/nobody_normal.png?d=1440683948",
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
}
