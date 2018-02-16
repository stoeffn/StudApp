//
//  FolderResponseTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class FolderResponseTests: XCTestCase {
    let decoder = ServiceContainer.default[JSONDecoder.self]

    func testInit_RootFolderData_RootFolder() {
        let folder = try! decoder.decode(FolderResponse.self, from: FolderResponseTests.rootFolderData)
        XCTAssertEqual(folder.id, "bc06c1df708390ba3597873de12e5469")
        XCTAssertEqual(folder.courseId, "a70c45ca747f0ab2ea4acbb17398d370")
        XCTAssertNil(folder.parentId)
        XCTAssertNil(folder.userId)
        XCTAssertEqual(folder.name, "Developer-Board")
        XCTAssertEqual(folder.createdAt.debugDescription, "2017-06-29 16:03:53 +0000")
        XCTAssertEqual(folder.modifiedAt.debugDescription, "2017-06-29 16:03:53 +0000")
        XCTAssertEqual(folder.summary, "S😂mmary")
        XCTAssertEqual(folder.folders.count, 1)
        XCTAssertEqual(folder.documents.count, 0)
    }

    func testInit_SubfolderData_Subfolder() {
        let folder = try! decoder.decode(FolderResponse.self, from: FolderResponseTests.subfolderData)
        XCTAssertEqual(folder.id, "e8471f3fde8c9c15a68e19e7691615d2")
        XCTAssertEqual(folder.courseId, "a70c45ca747f0ab2ea4acbb17398d370")
        XCTAssertEqual(folder.parentId, "bc06c1df708390ba3597873de12e5469")
        XCTAssertEqual(folder.userId, "4e89bbf43f0e31ecc0ca81e09d572e27")
        XCTAssertEqual(folder.name, "Adminsicht: Veranstaltungen an meinen Einrichtungen")
        XCTAssertEqual(folder.createdAt.debugDescription, "2014-03-21 18:30:46 +0000")
        XCTAssertEqual(folder.modifiedAt.debugDescription, "2014-03-21 18:30:46 +0000")
        XCTAssertNil(folder.summary)
        XCTAssertEqual(folder.folders.count, 0)
        XCTAssertEqual(folder.documents.count, 0)
    }

    func testInit_FolderData_Folder() {
        let folder = try! decoder.decode(FolderResponse.self, from: FolderResponseTests.folderData)
        XCTAssertEqual(folder.id, "2e84ba26c606e297f1bafd8fd524b19a")
        XCTAssertEqual(folder.courseId, "a70c45ca747f0ab2ea4acbb17398d370")
        XCTAssertEqual(folder.parentId, "f2a98e1fe606c64bb5e4954c382b8f89")
        XCTAssertEqual(folder.userId, "d7579498f7c5e5257a27b3b5c33b1e3b")
        XCTAssertEqual(folder.name, "10 Jahre Stud.IP")
        XCTAssertEqual(folder.createdAt.debugDescription, "2010-06-07 14:59:07 +0000")
        XCTAssertEqual(folder.modifiedAt.debugDescription, "2010-06-07 14:59:16 +0000")
        XCTAssertNil(folder.summary)
        XCTAssertEqual(folder.folders.count, 1)
        XCTAssertEqual(folder.documents.count, 1)
    }
}
