//
//  UserTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 07.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
@testable import StudKit
import XCTest

final class UserTests: XCTestCase {
    private let decoder = ServiceContainer.default[JSONDecoder.self]
    private var context: NSManagedObjectContext!

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext
    }

    // MARK: - Utilities

    func testNameComponents_User_Name() {
        let user = try! UserResponseTests.user0.coreDataObject(in: context)
        let expectedDescription = "namePrefix: Prefix givenName: First Name familyName: Last Name nameSuffix: Suffix "
        XCTAssertEqual(user.nameComponents.description, expectedDescription)
    }
}
