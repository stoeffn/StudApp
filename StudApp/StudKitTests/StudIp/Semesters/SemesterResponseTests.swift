//
//  SemesterResponseTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class SemesterResponseTests: XCTestCase {
    private let decoder = ServiceContainer.default[JSONDecoder.self]
    private var context: NSManagedObjectContext!

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext
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
        let semester = try! SemesterResponseTests.semester0.coreDataObject(in: context)
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
