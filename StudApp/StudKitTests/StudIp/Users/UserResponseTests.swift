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

import CoreData
@testable import StudKit
import XCTest

final class UserResponseTests: XCTestCase {
    private let decoder = ServiceContainer.default[JSONDecoder.self]
    private var context: NSManagedObjectContext!
    private lazy var organization = try! OrganizationRecord(id: "O0").coreDataObject(in: context)

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(context: Targets.Context(currentTarget: .tests))
            .provideCoreDataService().viewContext
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
        let user = try! UserResponseTests.user0.coreDataObject(organization: organization, in: context)
        XCTAssertEqual(user.id, "U0")
        XCTAssertEqual(user.username, "username")
        XCTAssertEqual(user.givenName, "First Name")
        XCTAssertEqual(user.familyName, "Last Name")
        XCTAssertEqual(user.namePrefix, "Prefix")
        XCTAssertEqual(user.nameSuffix, "Suffix")
    }
}
