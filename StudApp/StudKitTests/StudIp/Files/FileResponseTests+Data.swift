//
//  FileResponseTests+Data.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit

extension FileResponseTests {
    static let folder = FileResponse(folderId: "0", coursePath: "\\/api.php\\/course\\/0",
                                     children: [FileResponseTests.document], title: "Folder",
                                     ownerPath: "\\/api.php\\/user\\/Array")

    static let document = FileResponse(fileId: "1", name: "image.png", coursePath: "\\/api.php\\/course\\/0", parentId: "0",
                                       title: "Document", size: 42, downloadCount: 142, ownerPath: "\\/api.php\\/user\\/0")

    static let folderData = """
        {
            "folder_id": "e894bd27b2c3f5b25e438932f14b60e1",
            "name": "Title",
            "mkdate": 1467896155,
            "chdate": 1467896142,
            "course": "\\/api.php\\/course\\/a2c88e905abf322d1868640859f13c99",
            "range_id": "088f5f2efe1324e7296913bed9c1f93f",
            "author": "\\/api.php\\/user\\/Array"
        }
    """.data(using: .utf8)!

    static let emptyFolderData = """
        {
            "folder_id": "e894bd27b2c3f5b25e438932f14b60e1",
            "name": "Title",
            "mkdate": 1467896155,
            "chdate": 1467896142,
            "course": "\\/api.php\\/course\\/a2c88e905abf322d1868640859f13c99",
            "range_id": "088f5f2efe1324e7296913bed9c1f93f",
            "documents": []
        }
    """.data(using: .utf8)!

    static let documentData = """
        {
            "file_id": "e894bd27b2c3f5b25e438932f14b60e2",
            "name": "Title",
            "filename": "file.pdf",
            "filesize": 42,
            "mkdate": 1467896155,
            "chdate": 1467896142,
            "downloads": 142,
            "course": "\\/api.php\\/course\\/a2c88e905abf322d1868640859f13c99",
            "range_id": "088f5f2efe1324e7296913bed9c1f93f",
            "author": "\\/api.php\\/user\\/1234bd27b2c3f5b25e438932f14b60e1"
        }
    """.data(using: .utf8)!

    static let folderAndChildData = """
        {
            "folder_id": "e294bd27b2c3f5b25e438932f14b60e2",
            "name": "Title",
            "mkdate": 1467896155,
            "chdate": 1467896142,
            "course": "\\/api.php\\/course\\/a2c88e905abf322d1868640859f13c99",
            "range_id": "088f5f2efe1324e7296913bed9c1f93f",
            "documents": {
                "\\/api.php\\/file\\/e194bd27b2c3f5b25e438932f14b60e2": {
                    "file_id": "e194bd27b2c3f5b25e438932f14b60e2",
                    "name": "Title",
                    "filename": "file.pdf",
                    "filesize": 42,
                    "downloads": 142,
                    "mkdate": 1467896155,
                    "chdate": 1467896142,
                    "course": "\\/api.php\\/course\\/a2c88e905abf322d1868640859f13c99",
                    "range_id": "e294bd27b2c3f5b25e438932f14b60e2",
                    "author": "\\/api.php\\/user\\/1234bd27b2c3f5b25e438932f14b60e1"
                }
            }
        }
    """.data(using: .utf8)!
}
