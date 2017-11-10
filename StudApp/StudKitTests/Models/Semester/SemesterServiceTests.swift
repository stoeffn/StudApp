//
//  SemesterServiceTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//


import CoreData
import XCTest
@testable import StudKit

final class SemesterServiceTests : XCTestCase {
    let service = ServiceContainer.default[SemesterService.self]
    var context: NSManagedObjectContext!

    override func setUp() {
        context = StudKitTestsServiceProvider().provideCoreDataService().viewContext

        try! SemesterModel(id: "135de7259e0862cbcd3878e038253776", title: "Old title", beginDate: .distantFuture,
                           endDate: .distantFuture, coursesBeginDate: .distantFuture, coursesEndDate: .distantFuture)
            .coreDataModel(in: context)

        try! context!.save()
    }

    func testUpdate_SemesterCollectionResponse_Success() {
        service.updateSemesters(in: context) { semesterResult in
            try! self.context.save()
            let semester = try! Semester.fetch(byId: "135de7259e0862cbcd3878e038253776", in: self.context)

            XCTAssertTrue(semesterResult.isSuccess)
            XCTAssertEqual(try! Semester.fetch(in: self.context).count, 20)
            XCTAssertEqual(semester?.title, "WS 2008/09")
        }
    }
}
