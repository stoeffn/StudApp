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

extension FolderResponseTests {
    static let rootFolderData = """
        {
            "is_visible": true,
            "is_readable": true,
            "is_writable": true,
            "id": "bc06c1df708390ba3597873de12e5469",
            "user_id": "",
            "parent_id": "",
            "range_id": "a70c45ca747f0ab2ea4acbb17398d370",
            "range_type": "course",
            "folder_type": "RootFolder",
            "name": "Developer-Board",
            "data_content": [],
            "description": "S😂mmary",
            "mkdate": "1498752233",
            "chdate": "1498752233",
            "subfolders": [
                {
                    "id": "e8471f3fde8c9c15a68e19e7691615d2",
                    "user_id": "4e89bbf43f0e31ecc0ca81e09d572e27",
                    "parent_id": "bc06c1df708390ba3597873de12e5469",
                    "range_id": "a70c45ca747f0ab2ea4acbb17398d370",
                    "range_type": "course",
                    "folder_type": "StandardFolder",
                    "name": "Adminsicht: Veranstaltungen an meinen Einrichtungen",
                    "data_content": [],
                    "description": "",
                    "mkdate": "1395426646",
                    "chdate": "1395426646"
                }
            ]
        }
    """.data(using: .utf8)!

    static let subfolderData = """
        {
            "id": "e8471f3fde8c9c15a68e19e7691615d2",
            "user_id": "4e89bbf43f0e31ecc0ca81e09d572e27",
            "parent_id": "bc06c1df708390ba3597873de12e5469",
            "range_id": "a70c45ca747f0ab2ea4acbb17398d370",
            "range_type": "course",
            "folder_type": "StandardFolder",
            "name": "Adminsicht: Veranstaltungen an meinen Einrichtungen",
            "data_content": [],
            "description": "",
            "mkdate": "1395426646",
            "chdate": "1395426646"
        }
    """.data(using: .utf8)!

    static let folderData = """
        {
            "is_visible": true,
            "is_readable": true,
            "is_writable": true,
            "id": "2e84ba26c606e297f1bafd8fd524b19a",
            "user_id": "d7579498f7c5e5257a27b3b5c33b1e3b",
            "parent_id": "f2a98e1fe606c64bb5e4954c382b8f89",
            "range_id": "a70c45ca747f0ab2ea4acbb17398d370",
            "range_type": "course",
            "folder_type": "PermissionEnabledFolder",
            "name": "10 Jahre Stud.IP",
            "data_content": {
                "permission": "15"
            },
            "description": "",
            "mkdate": "1275922747",
            "chdate": "1275922756",
            "subfolders": [
                {
                    "id": "0d1a7ef750114913ced5e4335c76b712",
                    "user_id": "d7579498f7c5e5257a27b3b5c33b1e3b",
                    "parent_id": "2e84ba26c606e297f1bafd8fd524b19a",
                    "range_id": "a70c45ca747f0ab2ea4acbb17398d370",
                    "range_type": "course",
                    "folder_type": "PermissionEnabledFolder",
                    "name": "Logoaktion",
                    "data_content": {
                        "permission": "15"
                    },
                    "description": "",
                    "mkdate": "1275922774",
                    "chdate": "1275922911"
                }
            ],
            "file_refs": [
                {
                    "id": "8fe13c57f54861f0eeb7808b7a542c23",
                    "file_id": "8fe13c57f54861f0eeb7808b7a542c23",
                    "folder_id": "2e84ba26c606e297f1bafd8fd524b19a",
                    "downloads": "12",
                    "description": "Interview: 10 Jahre Stud.IP",
                    "content_terms_of_use_id": "0",
                    "user_id": "d7579498f7c5e5257a27b3b5c33b1e3b",
                    "name": "Interview_10_Jahre_StudIP.mp3",
                    "mkdate": "1286891014",
                    "chdate": "1286891014"
                }
            ]
        }
    """.data(using: .utf8)!

    static let rootFolder = FolderResponse(id: "F0", folders: [emptyFolder], documents: [])

    static let emptyFolder = FolderResponse(id: "F1", name: "Empty")

    static let folder = FolderResponse(id: "F2", userId: "U0", name: "Name", createdAt: Date(timeIntervalSince1970: 1),
                                       modifiedAt: Date(timeIntervalSince1970: 2), summary: "Sümmary",
                                       documents: [DocumentResponseTests.document1])
}
