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
        context = StudKitTestsServiceProvider().provideCoreDataService().viewContext

        try! SemesterModel(id: "0", title: "0", beginDate: Date(timeIntervalSince1970: 0),
                           endDate: Date(timeIntervalSince1970: 9), coursesBeginDate: .distantPast,
                           coursesEndDate: .distantPast).coreDataModel(in: context)
        try! SemesterModel(id: "1", title: "1", beginDate: Date(timeIntervalSince1970: 10),
                           endDate: Date(timeIntervalSince1970: 19), coursesBeginDate: .distantPast,
                           coursesEndDate: .distantPast).coreDataModel(in: context)
        try! SemesterModel(id: "2", title: "2", beginDate: Date(timeIntervalSince1970: 20),
                           endDate: Date(timeIntervalSince1970: 29), coursesBeginDate: .distantPast,
                           coursesEndDate: .distantPast).coreDataModel(in: context)
        try! SemesterModel(id: "3", title: "3", beginDate: Date(timeIntervalSince1970: 30),
                           endDate: Date(timeIntervalSince1970: 39), coursesBeginDate: .distantPast,
                           coursesEndDate: .distantPast).coreDataModel(in: context)

        try! CourseModel(id: "0", title: "A", beginSemesterPath: "/2").coreDataModel(in: context)
    }

    func testInit_SemesterModel_Semester() {
        let semester = try! SemesterModelTests.semester.coreDataModel(in: context) as! Semester
        XCTAssertEqual(semester.id, "0")
        XCTAssertEqual(semester.title, "Title")
        XCTAssertEqual(semester.beginDate, .distantPast)
        XCTAssertEqual(semester.endDate, .distantFuture)
        XCTAssertEqual(semester.coursesBeginDate, .distantPast)
        XCTAssertEqual(semester.coursesEndDate, .distantFuture)
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
