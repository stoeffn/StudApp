//
//  IdentifiableTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class IdentifiableTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! CourseResponse(id: "0", title: "A").coreDataModel(in: context)
        try! CourseResponse(id: "1", title: "B").coreDataModel(in: context)
        try! CourseResponse(id: "2", title: "C").coreDataModel(in: context)
    }

    func testFetchById_ExistingId_Course() {
        let course = try! Course.fetch(byId: "1", in: context)
        XCTAssertNotNil(course)
        XCTAssertEqual(course?.id, "1")
        XCTAssertEqual(course?.title, "B")
    }

    func testFetchById_MissingId_Nil() {
        let course = try! Course.fetch(byId: "abc", in: context)
        XCTAssertNil(course)
    }

    func testFetchByIds_Courses_Courses() {
        let courses = try! Course.fetch(byIds: ["0", "2"], in: context).sorted { $0.title < $1.title }
        XCTAssertEqual(courses[0].title, "A")
        XCTAssertEqual(courses[1].title, "C")
        XCTAssertEqual(courses.count, 2)
    }
}
