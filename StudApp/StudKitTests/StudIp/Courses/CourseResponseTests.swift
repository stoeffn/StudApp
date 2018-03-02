//
//  CourseResponseTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 24.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
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
