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

final class UserStudIpTests: XCTestCase {
    private var context: NSManagedObjectContext!
    private lazy var organization = try! OrganizationRecord(id: "O0").coreDataObject(in: context)
    private lazy var user = try! UserResponse(id: "U0").coreDataObject(organization: organization, in: context)

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(context: Targets.Context(currentTarget: .tests))
            .provideCoreDataService().viewContext

        try! CourseResponse(id: "0894bd27b2c3f5b25e438932f14b60e1").coreDataObject(organization: organization, in: context)
        try! CourseResponse(id: "e894bd27b2c3f5b25e438932f14b60e1").coreDataObject(organization: organization, in: context)
    }

    // MARK: - Updating Courses

    func testUpdate_CourseCollectionResponse_Success() {
        user.updateAuthoredCourses { result in
            let course = try! Course.fetch(byId: "e894bd27b2c3f5b25e438932f14b60e1", in: self.context)
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(try! Course.fetch(in: self.context).count, 31)
            XCTAssertEqual(course?.title, "Feedback-Forum zu Stud.IP")
        }
    }
}
