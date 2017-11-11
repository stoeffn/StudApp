//
//  FileModelTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import MobileCoreServices
import XCTest
@testable import StudKit

final class FileModelTests: XCTestCase {
    let decoder = ServiceContainer.default[JSONDecoder.self]
    var context: NSManagedObjectContext!

    override func setUp() {
        context = StudKitTestsServiceProvider().provideCoreDataService().viewContext

        try! CourseModel(id: "0", title: "A").coreDataModel(in: context)

        try! FileModel(folderId: "0", coursePath: "/0", title: "a").coreDataModel(in: context)
    }

    func testInit_FolderData_Folder() {
        let file = try! decoder.decode(FileModel.self, from: FileModelTests.folderData)
        XCTAssertEqual(file.typeIdentifier, kUTTypeFolder as String)
        XCTAssertEqual(file.id, "e894bd27b2c3f5b25e438932f14b60e1")
        XCTAssertEqual(file.name, "Title")
        XCTAssertEqual(file.size, nil)
        XCTAssertEqual(file.numberOfDownloads, nil)
        XCTAssertEqual(file.title, "Title")
        XCTAssertEqual(file.creationDate.debugDescription, "2016-07-07 12:55:55 +0000")
        XCTAssertEqual(file.modificationDate.debugDescription, "2016-07-07 12:55:42 +0000")
        XCTAssertEqual(file.ownerId, "Array")
    }

    func testInit_EmptyFolderData_Folder() {
        let file = try! decoder.decode(FileModel.self, from: FileModelTests.emptyFolderData)
        XCTAssertEqual(file.typeIdentifier, kUTTypeFolder as String)
        XCTAssertEqual(file.id, "e894bd27b2c3f5b25e438932f14b60e1")
        XCTAssertEqual(file.name, "Title")
        XCTAssertEqual(file.size, nil)
        XCTAssertEqual(file.numberOfDownloads, nil)
        XCTAssertEqual(file.title, "Title")
        XCTAssertEqual(file.creationDate.debugDescription, "2016-07-07 12:55:55 +0000")
        XCTAssertEqual(file.modificationDate.debugDescription, "2016-07-07 12:55:42 +0000")
        XCTAssertEqual(file.ownerId, nil)
    }

    func testInit_DocumentData_Document() {
        let file = try! decoder.decode(FileModel.self, from: FileModelTests.documentData)
        XCTAssertEqual(file.typeIdentifier, kUTTypePDF as String)
        XCTAssertEqual(file.id, "e894bd27b2c3f5b25e438932f14b60e2")
        XCTAssertEqual(file.name, "file.pdf")
        XCTAssertEqual(file.size, 42)
        XCTAssertEqual(file.numberOfDownloads, 142)
        XCTAssertEqual(file.title, "Title")
        XCTAssertEqual(file.creationDate.debugDescription, "2016-07-07 12:55:55 +0000")
        XCTAssertEqual(file.modificationDate.debugDescription, "2016-07-07 12:55:42 +0000")
        XCTAssertEqual(file.ownerId, "1234bd27b2c3f5b25e438932f14b60e1")
    }

    func testInit_FolderAndChildData_FolderAndChild() {
        let file = try! decoder.decode(FileModel.self, from: FileModelTests.folderAndChildData)
        XCTAssertEqual(file.typeIdentifier, kUTTypeFolder as String)
        XCTAssertEqual(file.children.count, 1)
        XCTAssertNotNil(file.children.first)
        XCTAssertEqual(file.children.first?.id, "e194bd27b2c3f5b25e438932f14b60e2")
    }

    func testInit_FileCollection_Files() {
        let collection = try! decoder.decode(CollectionResponse<FileModel>.self, fromResource: "fileCollection")
        XCTAssertEqual(collection.items.count, 6)
        XCTAssertEqual(collection.items.first?.children.count, 12)
    }

    func testId_Document_DocumentId() {
        XCTAssertEqual(FileModelTests.document.id, "1")
    }

    func testId_Folder_FolderId() {
        XCTAssertEqual(FileModelTests.folder.id, "0")
    }

    func testCourseId_CoursePath_CourseId() {
        XCTAssertEqual(FileModelTests.document.courseId, "0")
    }

    func testTypeIdentifier_Folder_FolderType() {
        XCTAssertEqual(FileModelTests.folder.typeIdentifier, kUTTypeFolder as String)
    }

    func testTypeIdentifier_Document_PngType() {
        XCTAssertEqual(FileModelTests.document.typeIdentifier, kUTTypePNG as String)
    }

    func testIsFolder_Document_False() {
        XCTAssertFalse(FileModelTests.document.isFolder)
    }

    func testIsFolder_Folder_True() {
        XCTAssertTrue(FileModelTests.folder.isFolder)
    }

    func testFetchCourse_File_Course() {
        let course = try! FileModelTests.document.fetchCourse(in: context)
        XCTAssertEqual(course?.id, "0")
    }

    func testFetchParent_Folder_Nil() {
        let file = try! FileModelTests.folder.fetchParent(in: context)
        XCTAssertNil(file)
    }

    func testFetchParent_Document_Folder() {
        let file = try! FileModelTests.document.fetchParent(in: context)
        XCTAssertNotNil(file)
        XCTAssertEqual(file?.id, "0")
    }
}
