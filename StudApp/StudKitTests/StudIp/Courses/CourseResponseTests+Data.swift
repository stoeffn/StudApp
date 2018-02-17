//
//  CourseResponseTests+Data.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
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
                                        summary: "Summary", lecturers: [UserResponse(id: "U0")], beginSemesterId: "S0",
                                        endSemesterId: "S1")
}
