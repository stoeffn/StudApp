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
