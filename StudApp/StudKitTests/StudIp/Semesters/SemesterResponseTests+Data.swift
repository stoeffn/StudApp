//
//  SemesterResponseTests+Data.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit

extension SemesterResponseTests {
    static let semester0Data = """
        {
            "id": "S0",
            "title": "SS 2009",
            "description": "Summary",
            "begin": 1238364000,
            "end": 1254347999,
            "seminars_begin": 1238364000,
            "seminars_end": 1246744799
        }
    """.data(using: .utf8)!

    static let semester1Data = """
        {
            "id": "S1",
            "title": "SS 2018",
            "description": "",
            "begin": 1238364000,
            "end": 1254347999,
            "seminars_begin": 1238364000,
            "seminars_end": 1246744799
        }
    """.data(using: .utf8)!

    static let semester0 = SemesterResponse(id: "S0", title: "Title", beginsAt: Date(timeIntervalSince1970: 1),
                                            endsAt: Date(timeIntervalSince1970: 4), coursesBeginAt: Date(timeIntervalSince1970: 2),
                                            coursesEndAt: Date(timeIntervalSince1970: 3), summary: "Summary")
}
