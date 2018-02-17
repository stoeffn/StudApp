//
//  UserResponseTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 07.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
@testable import StudKit
import XCTest

final class UserResponseTests: XCTestCase {
    private let decoder = ServiceContainer.default[JSONDecoder.self]
    private var context: NSManagedObjectContext!

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext
    }

    // MARK: - Coding

    func testInit_User0() {
        let user = try! decoder.decode(UserResponse.self, from: UserResponseTests.user0Data)
        XCTAssertEqual(user.id, "U0")
        XCTAssertEqual(user.username, "username")
        XCTAssertEqual(user.givenName, "First Name")
        XCTAssertEqual(user.familyName, "Last Name")
        XCTAssertEqual(user.namePrefix, "Prefix")
        XCTAssertEqual(user.nameSuffix, "Suffix")
        XCTAssertEqual(user.pictureModifiedAt?.description, "2015-08-27 13:59:08 +0000")
    }

    func testInit_User1() {
        let user = try! decoder.decode(UserResponse.self, from: UserResponseTests.user1Data)
        XCTAssertEqual(user.id, "U1")
        XCTAssertEqual(user.username, "username")
        XCTAssertEqual(user.givenName, "First Name")
        XCTAssertEqual(user.familyName, "Last Name")
        XCTAssertEqual(user.namePrefix, nil)
        XCTAssertEqual(user.nameSuffix, nil)
        XCTAssertEqual(user.pictureModifiedAt, nil)
    }

    // MARK: - Converting to a Core Data Object

    func testCoreDataObject_Uset0() {
        let user = try! UserResponseTests.user0.coreDataObject(in: context)
        XCTAssertEqual(user.id, "U0")
        XCTAssertEqual(user.username, "username")
        XCTAssertEqual(user.givenName, "First Name")
        XCTAssertEqual(user.familyName, "Last Name")
        XCTAssertEqual(user.namePrefix, "Prefix")
        XCTAssertEqual(user.nameSuffix, "Suffix")
    }
}
