//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

@testable import StudKit
import XCTest

final class FileManagerExtensionsTests: XCTestCase {
    private let storageService = ServiceContainer.default[StorageService.self]

    // MARK: - Life Cycle

    override func setUp() {
        let testFolder = BaseDirectories.downloads.url.appendingPathComponent("test", isDirectory: true)
        try? FileManager.default.removeItem(at: testFolder)
    }

    override func tearDown() {
        let testFolder = BaseDirectories.downloads.url.appendingPathComponent("test", isDirectory: true)
        try? FileManager.default.removeItem(at: testFolder)
    }

    // MARK: - Creating Intermediate Directories

    func testCreateIntermediateDirectories_NewUrl_Created() {
        let testFolderUrl = BaseDirectories.downloads.url.appendingPathComponent("test", isDirectory: true)
        let folder2Url = testFolderUrl.appendingPathComponent("folder2", isDirectory: true)
        let fileUrl = folder2Url.appendingPathComponent("file.pdf", isDirectory: false)
        try! FileManager.default.createIntermediateDirectories(forFileAt: fileUrl)

        XCTAssertTrue(FileManager.default.fileExists(atPath: testFolderUrl.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: folder2Url.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileUrl.path))
    }

    func testCreateIntermediateDirectories_ExistingUrl_Created() {
        let testFolderUrl = BaseDirectories.downloads.url.appendingPathComponent("test", isDirectory: true)
        let folder2Url = testFolderUrl.appendingPathComponent("folder2", isDirectory: true)
        let fileUrl = folder2Url.appendingPathComponent("file.pdf", isDirectory: false)
        try! FileManager.default.createDirectory(at: folder2Url, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createIntermediateDirectories(forFileAt: fileUrl)

        XCTAssertTrue(FileManager.default.fileExists(atPath: testFolderUrl.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: folder2Url.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileUrl.path))
    }
}
