//
//  DocumentResponseTests+Data.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

@testable import StudKit

extension DocumentResponseTests {
    static let document1Data = """
        {
            "id": "3b06880ecf63d7e3ac4f45b1947a09d9",
            "file_id": "3b06880ecf63d7e3ac4f45b1947a09d9",
            "folder_id": "e8471f3fde8c9c15a68e19e7691615d2",
            "downloads": "64",
            "size": "1024",
            "description": "Sümmary",
            "content_terms_of_use_id": "0",
            "user_id": "4e89bbf43f0e31ecc0ca81e09d572e27",
            "name": "variante_B_04.png",
            "mkdate": "1395426718",
            "chdate": "1395426718",
            "is_readable": true,
            "is_downloadable": true,
            "is_editable": false,
            "is_writable": false
        }
    """.data(using: .utf8)!

    static let document2Data = """
        {
            "id": "4b06880ecf63d7e3ac4f45b1947a09d9",
            "file_id": "4b06880ecf63d7e3ac4f45b1947a09d9",
            "folder_id": "e8471f3fde8c9c15a68e19e7691615d2",
            "description": "",
            "content_terms_of_use_id": "0",
            "user_id": "4e89bbf43f0e31ecc0ca81e09d572e27",
            "name": "variante_B_04.png",
            "mkdate": "1395426718",
            "chdate": "1395426718",
            "is_readable": true,
            "is_downloadable": true,
            "is_editable": false,
            "is_writable": false
        }
    """.data(using: .utf8)!

    static let document1 = DocumentResponse(id: "F0", parentId: "F1", userId: "U2", name: "file.pdf",
                                            createdAt: Date(timeIntervalSince1970: 10), modifiedAt: Date(timeIntervalSince1970: 20),
                                            summary: "Sümmary", size: 1024, downloadCount: 42)

    static let document2 = DocumentResponse(id: "F8", parentId: "F7", name: "image.png", createdAt: Date(timeIntervalSince1970: 1),
                                            modifiedAt: Date(timeIntervalSince1970: 2))
}
