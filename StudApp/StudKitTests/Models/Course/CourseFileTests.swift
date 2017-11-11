//
//  CourseFileTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class CourseFileTests: XCTestCase {
    let service = ServiceContainer.default[CourseService.self]
    var context: NSManagedObjectContext!
    var course: Course!

    override func setUp() {
        context = StudKitTestsServiceProvider().provideCoreDataService().viewContext

        course = try! CourseModel(id: "a2c88e905abf322d1868640859f13c99", title: "Course")
            .coreDataModel(in: context!) as? Course

        try! FileModel(fileId: "123456784c20d3c1931649b979ecd73e", name: "f.pdf",
                       coursePath: "/a2c88e905abf322d1868640859f13c99", title: "Current").coreDataModel(in: context!)
        try! FileModel(fileId: "d4a7bef74c20d3c1931649b979ecd73e", name: "file.pdf",
                       coursePath: "/a2c88e905abf322d1868640859f13c99", title: "Stale").coreDataModel(in: context!)

        try! context.save()
    }

    func testUpdateFiles_FileCollectionResponse_Success() {
        course!.updateFiles(in: context) { fileResult in
            try! self.context!.save()
            let course = try! Course.fetch(byId: "a2c88e905abf322d1868640859f13c99", in: self.context)
            let file = try! File.fetch(byId: "d4a7bef74c20d3c1931649b979ecd73e", in: self.context)

            XCTAssertTrue(fileResult.isSuccess)
            XCTAssertEqual(try! File.fetch(in: self.context!).count, 59)
            XCTAssertEqual(try! course!.fetchFiles(in: self.context).count, 7)
            XCTAssertEqual(file?.course.id, "a2c88e905abf322d1868640859f13c99")
            XCTAssertEqual(file?.title, "Leitfaden zur ErgebnisPIN")
        }
    }
}
