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

final class UserTests: XCTestCase {
    private let decoder = ServiceContainer.default[JSONDecoder.self]
    private var context: NSManagedObjectContext!
    private lazy var organization = try! OrganizationRecord(id: "O0").coreDataObject(in: context)

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext
    }

    // MARK: - Utilities

    func testNameComponents_User_Name() {
        let user = try! UserResponseTests.user0.coreDataObject(organization: organization, in: context)
        let expectedDescription = "namePrefix: Prefix givenName: First Name familyName: Last Name nameSuffix: Suffix "
        XCTAssertEqual(user.nameComponents.description, expectedDescription)
    }
}
