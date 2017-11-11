//
//  CourseModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

struct CourseModel: Decodable {
    let id: String
    private let rawNumber: String?
    let title: String
    let subtitle: String?
    let location: String?
    private let rawSummary: String?
    private let rawLecturers: [String: UserModel]
    private let beginSemesterPath: String
    private let endSemesterPath: String?

    enum CodingKeys: String, CodingKey {
        case id = "course_id"
        case rawNumber = "number"
        case title
        case subtitle
        case location
        case rawSummary = "description"
        case rawLecturers = "lecturers"
        case beginSemesterPath = "start_semester"
        case endSemesterPath = "end_semester"
    }

    init(id: String, rawNumber: String? = nil, title: String, subtitle: String? = nil, location: String? = nil,
         rawSummary: String? = nil, rawLecturers: [String: UserModel] = [:], beginSemesterPath: String = "",
         endSemesterPath: String? = nil) {
        self.id = id
        self.rawNumber = rawNumber
        self.title = title
        self.subtitle = subtitle
        self.location = location
        self.rawSummary = rawSummary
        self.rawLecturers = rawLecturers
        self.beginSemesterPath = beginSemesterPath
        self.endSemesterPath = endSemesterPath
    }

    var number: String? {
        return StudIp.transformCourseNumber(rawNumber)
    }

    var summary: String? {
        return StudIp.transformCourseSummary(rawSummary)
    }

    var lecturers: [UserModel] {
        return Array(rawLecturers.values)
    }

    var beginSemesterId: String? {
        return StudIp.transformIdPath(beginSemesterPath)
    }

    var endSemesterId: String? {
        return StudIp.transformIdPath(endSemesterPath)
    }
}
