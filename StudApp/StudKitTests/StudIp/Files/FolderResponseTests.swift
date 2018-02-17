//
//  FolderResponseTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import CoreData
import MobileCoreServices
import XCTest
@testable import StudKit

final class FolderResponseTests: XCTestCase {
    let decoder = ServiceContainer.default[JSONDecoder.self]
    var context: NSManagedObjectContext!

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! UserResponse(id: "U0").coreDataObject(in: context)
    }

    // MARK: - Coding

    func testInit_RootFolderData() {
        let folder = try! decoder.decode(FolderResponse.self, from: FolderResponseTests.rootFolderData)
        XCTAssertEqual(folder.id, "bc06c1df708390ba3597873de12e5469")
        XCTAssertNil(folder.userId)
        XCTAssertEqual(folder.name, "Developer-Board")
        XCTAssertEqual(folder.createdAt.debugDescription, "2017-06-29 16:03:53 +0000")
        XCTAssertEqual(folder.modifiedAt.debugDescription, "2017-06-29 16:03:53 +0000")
        XCTAssertEqual(folder.summary, "S😂mmary")
        XCTAssertEqual(folder.folders?.count, 1)
        XCTAssertNil(folder.documents)
    }

    func testInit_SubfolderData() {
        let folder = try! decoder.decode(FolderResponse.self, from: FolderResponseTests.subfolderData)
        XCTAssertEqual(folder.id, "e8471f3fde8c9c15a68e19e7691615d2")
        XCTAssertEqual(folder.userId, "4e89bbf43f0e31ecc0ca81e09d572e27")
        XCTAssertEqual(folder.name, "Adminsicht: Veranstaltungen an meinen Einrichtungen")
        XCTAssertEqual(folder.createdAt.debugDescription, "2014-03-21 18:30:46 +0000")
        XCTAssertEqual(folder.modifiedAt.debugDescription, "2014-03-21 18:30:46 +0000")
        XCTAssertNil(folder.summary)
        XCTAssertNil(folder.folders)
        XCTAssertNil(folder.documents)
    }

    func testInit_FolderData() {
        let folder = try! decoder.decode(FolderResponse.self, from: FolderResponseTests.folderData)
        XCTAssertEqual(folder.id, "2e84ba26c606e297f1bafd8fd524b19a")
        XCTAssertEqual(folder.userId, "d7579498f7c5e5257a27b3b5c33b1e3b")
        XCTAssertEqual(folder.name, "10 Jahre Stud.IP")
        XCTAssertEqual(folder.createdAt.debugDescription, "2010-06-07 14:59:07 +0000")
        XCTAssertEqual(folder.modifiedAt.debugDescription, "2010-06-07 14:59:16 +0000")
        XCTAssertNil(folder.summary)
        XCTAssertEqual(folder.folders?.count, 1)
        XCTAssertEqual(folder.documents?.count, 1)
    }

    func testInit_RootFolderResponse() {
        let folder = try! decoder.decode(FolderResponse.self, fromResource: "rootFolder")
        XCTAssertEqual(folder.folders?.count, 72)
        XCTAssertEqual(folder.documents?.count, 1)
    }

    // MARK: - Converting to Core Data Objects

    func testCoreDataObject_RootFolder() {
        let course0 = try! CourseResponse(id: "C0").coreDataObject(in: context)
        let folder = try! FolderResponseTests.rootFolder.coreDataObject(course: course0, in: context)
        XCTAssertEqual(folder.id, "F0")
        XCTAssertEqual(folder.name, "")
        XCTAssertEqual(folder.typeIdentifier, kUTTypeFolder as String)
        XCTAssertEqual(folder.size, -1)
        XCTAssertEqual(folder.course.id, "C0")
        XCTAssertNil(folder.parent)
        XCTAssertEqual(folder.downloadCount, -1)
        XCTAssertNil(folder.summary)
        XCTAssertNil(folder.owner)
        XCTAssertEqual(folder.children.count, 1)
        XCTAssertEqual(folder.children.first?.course.id, folder.course.id)
    }

    func testCoreDataObject_EmptyFolder() {
        let course0 = try! CourseResponse(id: "C0").coreDataObject(in: context)
        try! FolderResponseTests.rootFolder.coreDataObject(course: course0, in: context)
        let folder0 = try! FolderResponse(id: "F0").coreDataObject(course: course0, in: context)
        let folder = try! FolderResponseTests.emptyFolder.coreDataObject(course: course0, parent: folder0, in: context)
        XCTAssertEqual(folder.id, "F1")
        XCTAssertEqual(folder.name, "Empty")
        XCTAssertEqual(folder.typeIdentifier, kUTTypeFolder as String)
        XCTAssertEqual(folder.size, -1)
        XCTAssertEqual(folder.course.id, "C0")
        XCTAssertEqual(folder.parent?.id, "F0")
        XCTAssertEqual(folder.downloadCount, -1)
        XCTAssertNil(folder.summary)
        XCTAssertNil(folder.owner)
        XCTAssertEqual(folder.children.count, 0)
    }

    func testCoreDataObject_Folder() {
        let course0 = try! CourseResponse(id: "C0").coreDataObject(in: context)
        try! FolderResponseTests.rootFolder.coreDataObject(course: course0, in: context)
        let folder = try! FolderResponseTests.folder.coreDataObject(course: course0, in: context)
        XCTAssertEqual(folder.id, "F2")
        XCTAssertEqual(folder.name, "Name")
        XCTAssertEqual(folder.typeIdentifier, kUTTypeFolder as String)
        XCTAssertEqual(folder.size, -1)
        XCTAssertEqual(folder.course.id, "C0")
        XCTAssertNil(folder.parent)
        XCTAssertEqual(folder.createdAt, Date(timeIntervalSince1970: 1))
        XCTAssertEqual(folder.modifiedAt, Date(timeIntervalSince1970: 2))
        XCTAssertEqual(folder.downloadCount, -1)
        XCTAssertEqual(folder.summary, "Sümmary")
        XCTAssertEqual(folder.owner?.id, "U0")
        XCTAssertEqual(folder.children.count, 1)
        XCTAssertEqual(folder.children.first?.course.id, folder.course.id)
    }
}
