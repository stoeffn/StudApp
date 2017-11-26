//
//  SemesterResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

struct SemesterResponse: Decodable {
    let id: String
    let title: String
    let beginsAt: Date
    let endsAt: Date
    let coursesBeginAt: Date
    let coursesEndAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case beginsAt = "begin"
        case endsAt = "end"
        case coursesBeginAt = "seminars_begin"
        case coursesEndAt = "seminars_end"
    }
}
