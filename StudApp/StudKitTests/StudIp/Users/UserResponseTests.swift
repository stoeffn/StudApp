//
//  UserResponseTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 07.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class UserResponseTests: XCTestCase {
    let decoder = ServiceContainer.default[JSONDecoder.self]

    func testInit_UserData_User() {
        let user = try! decoder.decode(UserResponse.self, from: UserResponseTests.userData)
        XCTAssertEqual(user.id, "e894bd27b2c3f5b25e438932f14b60e1")
        XCTAssertEqual(user.username, "username")
        XCTAssertEqual(user.givenName, "First Name")
        XCTAssertEqual(user.familyName, "Last Name")
        XCTAssertEqual(user.namePrefix, "Prefix")
        XCTAssertEqual(user.nameSuffix, "Suffix")
        XCTAssertEqual(user.pictureModifiedAt?.description, "2015-08-27 13:59:08 +0000")
    }

    func testInit_UserWithoutPrefixAndPictureData_UserWithNilPrefix() {
        let user = try! decoder.decode(UserResponse.self, from: UserResponseTests.userWithoutPrefixAndPictureData)
        XCTAssertEqual(user.id, "e894bd27b2c3f5b25e438932f14b60e1")
        XCTAssertEqual(user.username, "username")
        XCTAssertEqual(user.givenName, "First Name")
        XCTAssertEqual(user.familyName, "Last Name")
        XCTAssertEqual(user.namePrefix, nil)
        XCTAssertEqual(user.nameSuffix, nil)
        XCTAssertEqual(user.pictureModifiedAt, nil)
    }
}
