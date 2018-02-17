//
//  AnnouncementResponseTests+Data.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 15.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit

extension AnnouncementResponseTests {
    static let announcement0Data = """
        {
            "news_id": "A0",
            "topic": "Weihnachtspause",
            "body": "Liebe Studierende,\\r\\n\\r\\ndies ist ein Test.",
            "date": "1513033200",
            "user_id": "U0",
            "expire": "2419140",
            "allow_comments": "1",
            "chdate": "1513079322",
            "chdate_uid": "",
            "mkdate": "1513079322",
            "body_html": "<div class=\\"formatted-content\\">Liebe Studierende,<br><br>dies ist ein Test.<\\/div>",
            "comments": "\\/api.php\\/news\\/A0\\/comments",
            "comments_count": 0,
            "ranges": [
                "\\/api.php\\/course\\/C0\\/news"
            ]
        }
    """.data(using: .utf8)!

    static let announcement1Data = """
        {
            "news_id": "A1",
            "topic": "Title",
            "body": "Another test.",
            "date": "1513033200",
            "user_id": "",
            "expire": "2419140",
            "allow_comments": "0",
            "chdate": "1513079322",
            "chdate_uid": "",
            "mkdate": "1513079322",
            "body_html": "<div class=\\"formatted-content\\">Liebe Studierende,<br><br>dies ist ein Test.<\\/div>",
            "comments": "\\/api.php\\/news\\/A0\\/comments",
            "comments_count": 0,
            "ranges": [
                "\\/api.php\\/course\\/C0\\/news",
                "\\/api.php\\/course\\/C1\\/news"
            ]
        }
    """.data(using: .utf8)!

    static let announcement0 = AnnouncementResponse(id: "A0", courseIds: ["C0", "C1"], userId: "U0",
                                                    createdAt: Date(timeIntervalSince1970: 1),
                                                    modifiedAt: Date(timeIntervalSince1970: 2),
                                                    expiresAfter: 3, title: "Title", body: "Body")
}
