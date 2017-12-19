//
//  CourseResponseTests+Data.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

extension CourseResponseTests {
    static let courseData = """
        {
            "course_id": "0",
            "number": "10062        ",
            "title": "Title",
            "subtitle": "Subtitle",
            "description": "<b>S&uuml;mmary</b>  Literatur: ",
            "location": "Location",
            "start_semester": "$0",
            "end_semester": "$1",
            "lecturers": {
                "\\/api.php\\/user\\/0": {
                    "id": "0",
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
}
