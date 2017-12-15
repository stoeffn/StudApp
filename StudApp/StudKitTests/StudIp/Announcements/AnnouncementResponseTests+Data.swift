//
//  AnnouncementResponseTests+Data.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 15.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit

extension AnnouncementResponseTests {
    static let announcementData = """
        {
            "news_id": "d8b6b4df0950483bc1911adfff93737b",
            "topic": "Weihnachtspause",
            "body": "Liebe Studierende,\\r\\n\\r\\ndies ist ein Test.",
            "date": "1513033200",
            "user_id": "1161ca9496cea513f9abd7ded50aac40",
            "expire": "2419140",
            "allow_comments": "1",
            "chdate": "1513079322",
            "chdate_uid": "",
            "mkdate": "1513079322",
            "body_html": "<div class=\\"formatted-content\\">Liebe Studierende,<br><br>dies ist ein Test.<\\/div>",
            "comments": "\\/api.php\\/news\\/d8b6b4df0950483bc1911adfff93737b\\/comments",
            "comments_count": 0,
            "ranges": [
                "\\/api.php\\/course\\/c9d9012189da913f029a1ab9a2781a98\\/news"
            ]
        }
    """.data(using: .utf8)!
}
