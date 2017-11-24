//
//  CourseServiceTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class CourseServiceTests: XCTestCase {
    let service = ServiceContainer.default[CourseService.self]
    var context: NSManagedObjectContext!

    override func setUp() {
        context = StudKitTestsServiceProvider(target: .tests).provideCoreDataService().viewContext

        try! CourseResponse(id: "0894bd27b2c3f5b25e438932f14b60e1", title: "Course 1").coreDataModel(in: context)
        try! CourseResponse(id: "e894bd27b2c3f5b25e438932f14b60e1", title: "Stale Feedback").coreDataModel(in: context)

        try! context!.save()

        try! FileResponse(fileId: "4594bd27b2c3f5b25e438932f14b60e1", name: "file.pdf",
                          coursePath: "/e894bd27b2c3f5b25e438932f14b60e1", title: "File")
            .coreDataModel(in: context)

        try! context!.save()
    }

    func testUpdate_CourseCollectionResponse_Success() {
        service.update(in: context) { courseResult in
            try! self.context.save()
            let course = try! Course.fetch(byId: "e894bd27b2c3f5b25e438932f14b60e1", in: self.context)

            XCTAssertTrue(courseResult.isSuccess)
            XCTAssertEqual(try! Course.fetch(in: self.context).count, 32)
            XCTAssertEqual(course?.title, "Feedback-Forum zu Stud.IP")
            XCTAssertEqual(course?.files.count, 1)
        }
    }
}
