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

final class SemesterResponseTests: XCTestCase {
    private let decoder = ServiceContainer.default[JSONDecoder.self]
    private var context: NSManagedObjectContext!
    private lazy var organization = try! OrganizationRecord(id: "O0").coreDataObject(in: context)

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(context: Targets.Context(currentTarget: .tests))
            .provideCoreDataService().viewContext
    }

    // MARK: - Coding

    func testInit_Semester0Data() {
        let semester = try! decoder.decode(SemesterResponse.self, from: SemesterResponseTests.semester0Data)
        XCTAssertEqual(semester.id, "S0")
        XCTAssertEqual(semester.title, "SS 2009")
        XCTAssertEqual(semester.beginsAt.description, "2009-03-29 22:00:00 +0000")
        XCTAssertEqual(semester.endsAt.description, "2009-09-30 21:59:59 +0000")
        XCTAssertEqual(semester.coursesBeginAt.description, "2009-03-29 22:00:00 +0000")
        XCTAssertEqual(semester.coursesEndAt.description, "2009-07-04 21:59:59 +0000")
        XCTAssertEqual(semester.summary, "Summary")
    }

    func testInit_Semester1Data() {
        let semester = try! decoder.decode(SemesterResponse.self, from: SemesterResponseTests.semester1Data)
        XCTAssertEqual(semester.id, "S1")
        XCTAssertEqual(semester.title, "SS 2018")
        XCTAssertEqual(semester.beginsAt.description, "2009-03-29 22:00:00 +0000")
        XCTAssertEqual(semester.endsAt.description, "2009-09-30 21:59:59 +0000")
        XCTAssertEqual(semester.coursesBeginAt.description, "2009-03-29 22:00:00 +0000")
        XCTAssertEqual(semester.coursesEndAt.description, "2009-07-04 21:59:59 +0000")
        XCTAssertNil(semester.summary)
    }

    func testInit_SemesterCollection() {
        let collection = try! decoder.decode(CollectionResponse<SemesterResponse>.self, fromResource: "semesterCollection")
        XCTAssertEqual(collection.items.count, 20)
    }

    // MARK: - Converting to a Core Data Object

    func testCoreDataObject_Semester0() {
        let semester = try! SemesterResponseTests.semester0.coreDataObject(organization: organization, in: context)
        XCTAssertEqual(semester.id, "S0")
        XCTAssertEqual(semester.title, "Title")
        XCTAssertEqual(semester.beginsAt, Date(timeIntervalSince1970: 1))
        XCTAssertEqual(semester.endsAt, Date(timeIntervalSince1970: 4))
        XCTAssertEqual(semester.coursesBeginAt, Date(timeIntervalSince1970: 2))
        XCTAssertEqual(semester.coursesEndAt, Date(timeIntervalSince1970: 3))
        XCTAssertEqual(semester.summary, "Summary")
        XCTAssertTrue(semester.state.isHidden)
    }
}
