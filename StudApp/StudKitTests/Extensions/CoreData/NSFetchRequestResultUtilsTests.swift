//
//  NSFetchRequestResultUtilsTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
@testable import StudKit
import XCTest

final class NSFetchRequestResultUtilsTests: XCTestCase {
    private var context: NSManagedObjectContext!
    private lazy var organization = try! OrganizationRecord(id: "O0").coreDataObject(in: context)

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! CourseResponse(id: "C0").coreDataObject(organization: organization, in: context)
        try! CourseResponse(id: "C1").coreDataObject(organization: organization, in: context)
    }

    // MARK: - Fetching

    func testFetch_All() {
        let courses = try! Course.fetch(in: context)
        XCTAssertEqual(Set(courses.map { $0.id }), ["C0", "C1"])
    }
}
