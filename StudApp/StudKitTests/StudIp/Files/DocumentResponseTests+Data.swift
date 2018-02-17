//
//  DocumentResponseTests+Data.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

@testable import StudKit

extension DocumentResponseTests {
    static let document0Data = """
        {
            "id": "F0",
            "file_id": "F0",
            "folder_id": "F2",
            "downloads": "64",
            "size": "1024",
            "description": "Sümmary",
            "content_terms_of_use_id": "0",
            "user_id": "U0",
            "name": "variante_B_04.png",
            "mkdate": "1395426718",
            "chdate": "1395426718",
            "is_readable": true,
            "is_downloadable": true,
            "is_editable": false,
            "is_writable": false
        }
    """.data(using: .utf8)!

    static let document1Data = """
        {
            "id": "F1",
            "file_id": "F1",
            "folder_id": "F2",
            "description": "",
            "content_terms_of_use_id": "0",
            "user_id": "",
            "name": "variante_B_04.png",
            "mkdate": "1395426718",
            "chdate": "1395426718",
            "is_readable": true,
            "is_downloadable": true,
            "is_editable": false,
            "is_writable": false
        }
    """.data(using: .utf8)!

    static let document0 = DocumentResponse(id: "F0", userId: "U0", name: "file.pdf", createdAt: Date(timeIntervalSince1970: 10),
                                            modifiedAt: Date(timeIntervalSince1970: 20), summary: "Sümmary", size: 1024,
                                            downloadCount: 42)

    static let document1 = DocumentResponse(id: "F1", name: "image.png", createdAt: Date(timeIntervalSince1970: 1),
                                            modifiedAt: Date(timeIntervalSince1970: 2))
}
