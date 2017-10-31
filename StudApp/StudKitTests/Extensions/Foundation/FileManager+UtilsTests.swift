//
//  FileManager+UtilsTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 30.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class FileManagerExtensionsTests : XCTestCase {
    let storageService = ServiceContainer.default[StorageService.self]

    override func setUp() {
        let testFolder = storageService.documentsUrl.appendingPathComponent("test", isDirectory: true)
        try? FileManager.default.removeItem(at: testFolder)
    }

    func testCreateIntermediateDirectories_NewUrl_Created() {
        let testFolderUrl = storageService.documentsUrl.appendingPathComponent("test", isDirectory: true)
        let folder2Url = testFolderUrl.appendingPathComponent("folder2", isDirectory: true)
        let fileUrl = folder2Url.appendingPathComponent("file.pdf", isDirectory: false)
        try! FileManager.default.createIntermediateDirectories(forFileAt: fileUrl)

        XCTAssertTrue(FileManager.default.fileExists(atPath: testFolderUrl.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: folder2Url.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileUrl.path))
    }

    func testCreateIntermediateDirectories_ExistingUrl_Created() {
        let testFolderUrl = storageService.documentsUrl.appendingPathComponent("test", isDirectory: true)
        let folder2Url = testFolderUrl.appendingPathComponent("folder2", isDirectory: true)
        let fileUrl = folder2Url.appendingPathComponent("file.pdf", isDirectory: false)
        try! FileManager.default.createDirectory(at: folder2Url, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createIntermediateDirectories(forFileAt: fileUrl)

        XCTAssertTrue(FileManager.default.fileExists(atPath: testFolderUrl.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: folder2Url.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileUrl.path))
    }
}
