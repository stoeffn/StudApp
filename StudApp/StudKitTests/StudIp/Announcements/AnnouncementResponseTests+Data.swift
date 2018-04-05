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
                                                    expiresAfter: 3, title: "Title", htmlContent: "Body")
}
