//
//  CourseTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
@testable import StudKit
import XCTest

final class CourseTests: XCTestCase {
    private var context: NSManagedObjectContext!
    private lazy var organization = try! OrganizationRecord(id: "O0").coreDataObject(in: context)
    private lazy var user = try! UserResponse(id: "U0").coreDataObject(organization: organization, in: context)

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! SemesterResponse(id: "S0", beginsAt: Date(timeIntervalSince1970: 0), endsAt: Date(timeIntervalSince1970: 9))
            .coreDataObject(organization: organization, in: context)
        try! SemesterResponse(id: "S1", beginsAt: Date(timeIntervalSince1970: 10), endsAt: Date(timeIntervalSince1970: 19))
            .coreDataObject(organization: organization, in: context)

        try! CourseResponse(id: "C0", beginSemesterId: "S0", endSemesterId: "S0")
            .coreDataObject(organization: organization, author: user, in: context)
        try! CourseResponse(id: "C1", beginSemesterId: "S0", endSemesterId: "S0")
            .coreDataObject(organization: organization, author: user, in: context)
        try! CourseResponse(id: "C2", beginSemesterId: "S0", endSemesterId: "S1")
            .coreDataObject(organization: organization, author: user, in: context)
        try! CourseResponse(id: "C3", beginSemesterId: "S1", endSemesterId: "S1")
            .coreDataObject(organization: organization, author: user, in: context)
    }

    // MARK: - Fetching Courses in a Semester

    func testBySemester_0_3Courses() {
        let semester = try! Semester.fetch(byId: "S0", in: context)
        let courses = try! context.fetch(user.authoredCoursesFetchRequest(in: semester))
        XCTAssertEqual(Set(courses.map { $0.id }), ["C0", "C1", "C2"])
    }

    func testBySemester_1_2Courses() {
        let semester = try! Semester.fetch(byId: "S1", in: context)
        let courses = try! context.fetch(user.authoredCoursesFetchRequest(in: semester))
        XCTAssertEqual(Set(courses.map { $0.id }), ["C2", "C3"])
    }
}
