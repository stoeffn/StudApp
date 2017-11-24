//
//  SemesterResponseTests+Data.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit

extension SemesterResponseTests {
    static let semester = SemesterResponse(id: "0", title: "Title", beginDate: .distantPast,
                                           endDate: .distantFuture, coursesBeginDate: .distantPast,
                                           coursesEndDate: .distantFuture)

    static let semesterData = """
        {
            "id": "1",
            "title": "SS 2009",
            "description": "",
            "begin": 1238364000,
            "end": 1254347999,
            "seminars_begin": 1238364000,
            "seminars_end": 1246744799
        }
    """.data(using: .utf8)!
}
