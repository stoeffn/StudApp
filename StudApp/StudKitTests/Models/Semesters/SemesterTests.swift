//
//  SemesterTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class SemesterTests: XCTestCase {
    let decoder = ServiceContainer.default[JSONDecoder.self]
    var context: NSManagedObjectContext!

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! SemesterResponse(id: "0", title: "0", beginsAt: Date(timeIntervalSince1970: 0),
                              endsAt: Date(timeIntervalSince1970: 9), coursesBeginAt: .distantPast,
                              coursesEndAt: .distantPast).coreDataModel(in: context)
        try! SemesterResponse(id: "1", title: "1", beginsAt: Date(timeIntervalSince1970: 10),
                              endsAt: Date(timeIntervalSince1970: 19), coursesBeginAt: .distantPast,
                              coursesEndAt: .distantPast).coreDataModel(in: context)
        try! SemesterResponse(id: "2", title: "2", beginsAt: Date(timeIntervalSince1970: 20),
                              endsAt: Date(timeIntervalSince1970: 29), coursesBeginAt: .distantPast,
                              coursesEndAt: .distantPast).coreDataModel(in: context)
        try! SemesterResponse(id: "3", title: "3", beginsAt: Date(timeIntervalSince1970: 30),
                              endsAt: Date(timeIntervalSince1970: 39), coursesBeginAt: .distantPast,
                              coursesEndAt: .distantPast).coreDataModel(in: context)

        try! CourseResponse(id: "0", title: "A", beginSemesterPath: "/2").coreDataModel(in: context)
    }

    func testInit_SemesterModel_Semester() {
        let semester = try! SemesterResponseTests.semester.coreDataModel(in: context) as! Semester
        XCTAssertEqual(semester.id, "0")
        XCTAssertEqual(semester.title, "Title")
        XCTAssertEqual(semester.beginsAt, .distantPast)
        XCTAssertEqual(semester.endsAt, .distantFuture)
        XCTAssertEqual(semester.coursesBeginAt, .distantPast)
        XCTAssertEqual(semester.coursesEndAt, .distantFuture)
        XCTAssertNotNil(semester.state)
    }

    func testFetchFrom_1to2_12() {
        let from = try! Semester.fetch(byId: "1", in: context)
        let to = try! Semester.fetch(byId: "2", in: context)
        let semesters = try! Semester.fetch(from: from!, to: to, in: context)
        XCTAssertEqual(semesters.map { $0.id }.set, ["1", "2"] as Set)
    }

    func testFetchFrom_1to3_123() {
        let from = try! Semester.fetch(byId: "1", in: context)
        let to = try! Semester.fetch(byId: "3", in: context)
        let semesters = try! Semester.fetch(from: from!, to: to, in: context)
        XCTAssertEqual(semesters.map { $0.id }.set, ["1", "2", "3"] as Set)
    }

    func testFetchFrom_2_23() {
        let from = try! Semester.fetch(byId: "2", in: context)
        let semesters = try! Semester.fetch(from: from!, in: context)
        XCTAssertEqual(semesters.map { $0.id }.set, ["2", "3"] as Set)
    }
}
