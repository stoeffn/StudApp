//
//  Semester+StudIpTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
@testable import StudKit
import XCTest

final class SemesterStudIpTests: XCTestCase {
    private var context: NSManagedObjectContext!

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! SemesterResponse(id: "135de7259e0862cbcd3878e038253776").coreDataObject(in: context)
    }

    // MARK: - Updating Semesters

    func testUpdate_SemesterCollectionResponse() {
        Semester.update(in: context) { result in
            let semester = try! Semester.fetch(byId: "135de7259e0862cbcd3878e038253776", in: self.context)
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(try! Semester.fetch(in: self.context).count, 20)
            XCTAssertEqual(semester?.title, "WS 2008/09")
        }
    }
}
