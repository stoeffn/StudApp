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
        context = StudKitTestsServiceProvider(target: .tests).provideCoreDataService().viewContext

        try! CourseResponse(id: "0", title: "A").coreDataModel(in: context)
        try! CourseResponse(id: "1", title: "B").coreDataModel(in: context)
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
}
