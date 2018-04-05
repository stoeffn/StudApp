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

final class CourseResponseTests: XCTestCase {
    private let decoder = ServiceContainer.default[JSONDecoder.self]
    private var context: NSManagedObjectContext!
    private lazy var organization = try! OrganizationRecord(id: "O0").coreDataObject(in: context)

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! SemesterResponse(id: "S0").coreDataObject(organization: organization, in: context)
        try! SemesterResponse(id: "S1").coreDataObject(organization: organization, in: context)
    }

    // MARK: - Coding

    func testInit_Course0() {
        let course = try! decoder.decode(CourseResponse.self, from: CourseResponseTests.course0Data)
        XCTAssertEqual(course.id, "C0")
        XCTAssertEqual(course.number, "10062")
        XCTAssertEqual(course.title, "Title")
        XCTAssertEqual(course.subtitle, "Subtitle")
        XCTAssertEqual(course.location, "Location")
        XCTAssertEqual(course.summary, "Sümmary")
        XCTAssertEqual(course.groupId, 2)
        XCTAssertEqual(course.lecturers.count, 1)
        XCTAssertEqual(course.lecturers.first?.id, "U0")
        XCTAssertEqual(course.beginSemesterId, "S0")
        XCTAssertEqual(course.endSemesterId, "S1")
    }

    func testInit_Course1() {
        let course = try! decoder.decode(CourseResponse.self, from: CourseResponseTests.course1Data)
        XCTAssertEqual(course.id, "C1")
        XCTAssertNil(course.number)
        XCTAssertEqual(course.title, "Title")
        XCTAssertNil(course.subtitle)
        XCTAssertNil(course.location)
        XCTAssertNil(course.summary)
        XCTAssertEqual(course.groupId, 0)
        XCTAssertEqual(course.lecturers.count, 0)
        XCTAssertNil(course.beginSemesterId)
        XCTAssertNil(course.endSemesterId)
    }

    func testInit_CourseCollection_Courses() {
        let collection = try! decoder.decode(CollectionResponse<CourseResponse>.self, fromResource: "courseCollection")
        XCTAssertEqual(collection.items.count, 20)
    }

    // MARK: - Converting to a Core Data Object

    func testCoreDataObject_Course0() {
        let course = try! CourseResponseTests.course0.coreDataObject(organization: organization, in: context)
        XCTAssertEqual(course.id, "C0")
        XCTAssertEqual(course.number, "123")
        XCTAssertEqual(course.title, "Title")
        XCTAssertEqual(course.subtitle, "Subtitle")
        XCTAssertEqual(course.summary, "Summary")
        XCTAssertEqual(course.groupId, 2)
        XCTAssertEqual(course.location, "Location")
        XCTAssertEqual(Set(course.lecturers.map { $0.id }), ["U0"])
        XCTAssertEqual(Set(course.semesters.map { $0.id }), ["S0", "S1"])
    }
}
