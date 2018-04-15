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

extension CourseResponseTests {
    static let course0Data = """
        {
            "course_id": "C0",
            "number": "10062        ",
            "title": "Title",
            "subtitle": "Subtitle",
            "description": "<b>S&uuml;mmary</b>  Literatur: ",
            "location": "Location",
            "group": 2,
            "start_semester": "S0",
            "end_semester": "S1",
            "lecturers": {
                "\\/api.php\\/user\\/U0": {
                    "id": "U0",
                    "name": {
                        "username": "username",
                        "formatted": "Formatted",
                        "family": "User",
                        "given": "Test",
                        "prefix": "Dr.",
                        "suffix": ""
                    }
                }
            }
        }
    """.data(using: .utf8)!

    static let course1Data = """
        {
            "course_id": "C1",
            "number": "   ",
            "title": "Title",
            "subtitle": "",
            "description": " Literatur: ",
            "location": "",
            "start_semester": "",
            "end_semester": "",
            "lecturers": {}
        }
    """.data(using: .utf8)!

    static let course0 = CourseResponse(id: "C0", number: "123", title: "Title", subtitle: "Subtitle", location: "Location",
                                        summary: "Summary", groupId: 2, lecturers: [UserResponse(id: "U0")],
                                        beginSemesterId: "S0", endSemesterId: "S1")
}
