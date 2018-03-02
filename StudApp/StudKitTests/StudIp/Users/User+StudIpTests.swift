//
//  User+StudIpTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
@testable import StudKit
import XCTest

final class UserStudIpTests: XCTestCase {
    private var context: NSManagedObjectContext!
    private lazy var organization = try! OrganizationRecord(id: "O0").coreDataObject(in: context)
    private lazy var user = try! UserResponse(id: "U0").coreDataObject(organization: organization, in: context)

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! CourseResponse(id: "0894bd27b2c3f5b25e438932f14b60e1").coreDataObject(organization: organization, in: context)
        try! CourseResponse(id: "e894bd27b2c3f5b25e438932f14b60e1").coreDataObject(organization: organization, in: context)
    }

    // MARK: - Updating Courses

    func testUpdate_CourseCollectionResponse_Success() {
        user.updateAuthoredCourses { result in
            let course = try! Course.fetch(byId: "e894bd27b2c3f5b25e438932f14b60e1", in: self.context)
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(try! Course.fetch(in: self.context).count, 31)
            XCTAssertEqual(course?.title, "Feedback-Forum zu Stud.IP")
        }
    }
}
