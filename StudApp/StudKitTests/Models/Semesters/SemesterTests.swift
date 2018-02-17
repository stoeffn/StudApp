//
//  SemesterTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
@testable import StudKit
import XCTest

final class SemesterTests: XCTestCase {
    private let decoder = ServiceContainer.default[JSONDecoder.self]
    private var context: NSManagedObjectContext!

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! SemesterResponse(id: "S0", beginsAt: Date(timeIntervalSince1970: 0), endsAt: Date(timeIntervalSince1970: 9))
            .coreDataObject(in: context)
        try! SemesterResponse(id: "S1", beginsAt: Date(timeIntervalSince1970: 10), endsAt: Date(timeIntervalSince1970: 19))
            .coreDataObject(in: context)
        try! SemesterResponse(id: "S2", beginsAt: Date(timeIntervalSince1970: 20), endsAt: Date(timeIntervalSince1970: 29))
            .coreDataObject(in: context)
        try! SemesterResponse(id: "S3", beginsAt: Date(timeIntervalSince1970: 30), endsAt: Date(timeIntervalSince1970: 39))
            .coreDataObject(in: context)

        try! CourseResponse(id: "C0", beginSemesterId: "S2").coreDataObject(in: context)
    }

    // MARK: - Fetching

    func testFetchFrom_1to2_12() {
        let from = try! Semester.fetch(byId: "S1", in: context)
        let to = try! Semester.fetch(byId: "S2", in: context)
        let semesters = try! Semester.fetch(from: from!, to: to, in: context)
        XCTAssertEqual(Set(semesters.map { $0.id }), ["S1", "S2"])
    }

    func testFetchFrom_1to3_123() {
        let from = try! Semester.fetch(byId: "S1", in: context)
        let to = try! Semester.fetch(byId: "S3", in: context)
        let semesters = try! Semester.fetch(from: from!, to: to, in: context)
        XCTAssertEqual(Set(semesters.map { $0.id }), ["S1", "S2", "S3"])
    }

    func testFetchFrom_2_23() {
        let from = try! Semester.fetch(byId: "S2", in: context)
        let semesters = try! Semester.fetch(from: from!, in: context)
        XCTAssertEqual(Set(semesters.map { $0.id }), ["S2", "S3"])
    }
}
