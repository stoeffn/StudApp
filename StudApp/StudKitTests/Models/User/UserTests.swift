//
//  UserTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 07.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class UserTests: XCTestCase {
    let decoder = ServiceContainer.default[JSONDecoder.self]
    var context: NSManagedObjectContext!

    override func setUp() {
        context = StudKitTestsServiceProvider(target: .tests).provideCoreDataService().viewContext
    }

    func testInit_UserModel_User() {
        let user = try! UserModelTests.user.coreDataModel(in: context) as! User
        XCTAssertEqual(user.id, "0")
        XCTAssertEqual(user.username, "username")
        XCTAssertEqual(user.givenName, "First Name")
        XCTAssertEqual(user.familyName, "Last Name")
        XCTAssertEqual(user.namePrefix, "Prefix")
        XCTAssertEqual(user.nameSuffix, "Suffix")
    }

    func testNameComponents_User_Name() {
        let user = try! UserModelTests.user.coreDataModel(in: context) as! User
        XCTAssertEqual(user.nameComponents.description,
                       "namePrefix: Prefix givenName: First Name familyName: Last Name nameSuffix: Suffix ")
    }
}
