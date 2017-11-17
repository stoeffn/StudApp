//
//  FileTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 24.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class FileTests: XCTestCase {
    let decoder = ServiceContainer.default[JSONDecoder.self]
    var context: NSManagedObjectContext!

    override func setUp() {
        context = StudKitTestsServiceProvider(target: .tests).provideCoreDataService().viewContext

        try! CourseModel(id: "0", title: "A").coreDataModel(in: context)
        try! CourseModel(id: "a2c88e905abf322d1868640859f13c99", title: "B").coreDataModel(in: context)

        try! UserModel(id: "0", username: "A", givenName: "Test", familyName: "User").coreDataModel(in: context)
    }

    func testInit_FileModel_File() {
        let folder = try! FileModelTests.folder.coreDataModel(in: context) as! File
        let document = folder.children.first

        XCTAssertEqual(folder.id, "0")
        XCTAssertEqual(folder.title, "Folder")
        XCTAssertEqual(folder.owner, nil)
        XCTAssertEqual(folder.course.id, "0")
        XCTAssertNotNil(document)
        XCTAssertEqual(document?.id, "1")
        XCTAssertEqual(document?.size, 42)
        XCTAssertEqual(document?.numberOfDownloads, 142)
        XCTAssertEqual(document?.owner?.id, "0")
        XCTAssertEqual(document?.course.id, "0")
        XCTAssertEqual(document?.parent?.id, "0")
        XCTAssertNotNil(folder.state)
        XCTAssertNotNil(document?.state)
    }

    func testInit_Collection_Files() {
        let files = try! decoder.decode(CollectionResponse<FileModel>.self, fromResource: "fileCollection").items
            .flatMap { try! $0.coreDataModel(in: context) as? File }

        XCTAssertEqual(files.count, 6)
        XCTAssertEqual(files.first?.children.count, 12)
    }
}
