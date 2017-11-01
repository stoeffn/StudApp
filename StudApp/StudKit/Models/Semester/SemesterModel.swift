//
//  SemesterModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

struct SemesterModel : Decodable {
    let id: String
    let title: String
    let beginDate: Date
    let endDate: Date
    let coursesBeginDate: Date
    let coursesEndDate: Date

    enum CodingKeys : String, CodingKey {
        case id
        case title
        case beginDate = "begin"
        case endDate = "end"
        case coursesBeginDate = "seminars_begin"
        case coursesEndDate = "seminars_end"
    }
}
