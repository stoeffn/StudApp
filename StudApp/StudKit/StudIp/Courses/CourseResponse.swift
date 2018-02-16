//
//  CourseResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

/// Represents a decoded course object as returned by the API.
struct CourseResponse: Decodable {
    let id: String
    private let rawNumber: String?
    let title: String
    private let rawSubtitle: String?
    private let rawLocation: String?
    private let rawSummary: String?
    private let rawLecturers: [String: UserResponse]
    private let beginSemesterPath: String?
    private let endSemesterPath: String?

    enum CodingKeys: String, CodingKey {
        case id = "course_id"
        case rawNumber = "number"
        case title
        case rawSubtitle = "subtitle"
        case rawLocation = "location"
        case rawSummary = "description"
        case rawLecturers = "lecturers"
        case beginSemesterPath = "start_semester"
        case endSemesterPath = "end_semester"
    }

    init(id: String, rawNumber: String? = nil, title: String, rawSubtitle: String? = nil, rawLocation: String? = nil,
         rawSummary: String? = nil, rawLecturers: [String: UserResponse] = [:], beginSemesterPath: String? = nil,
         endSemesterPath: String? = nil) {
        self.id = id
        self.rawNumber = rawNumber
        self.title = title
        self.rawSubtitle = rawSubtitle
        self.rawLocation = rawLocation
        self.rawSummary = rawSummary
        self.rawLecturers = rawLecturers
        self.beginSemesterPath = beginSemesterPath
        self.endSemesterPath = endSemesterPath
    }
}

// MARK: - Utilities

extension CourseResponse {
    var number: String? {
        return StudIp.transformCourseNumber(rawNumber)
    }

    var subtitle: String? {
        return rawSubtitle?.nilWhenEmpty
    }

    var location: String? {
        return rawLocation?.nilWhenEmpty
    }

    var summary: String? {
        return StudIp.transformCourseSummary(rawSummary)
    }

    var lecturers: [UserResponse] {
        return Array(rawLecturers.values)
    }

    var beginSemesterId: String? {
        return StudIp.transformIdPath(beginSemesterPath)
    }

    var endSemesterId: String? {
        return StudIp.transformIdPath(endSemesterPath)
    }
}

// MARK: - Converting to a Core Data Object

extension CourseResponse {
    @discardableResult
    func coreDataObject(in context: NSManagedObjectContext) throws -> Course {
        let (course, _) = try Course.fetch(byId: id, orCreateIn: context)
        let beginSemester = try Semester.fetch(byId: beginSemesterId, in: context)
        let endSemester = try Semester.fetch(byId: endSemesterId, in: context)
        let semesters = try Semester.fetch(from: beginSemester, to: endSemester, in: context)
        let lecturers = try self.lecturers.map { try $0.coreDataObject(in: context) }
        course.id = id
        course.number = number
        course.title = title
        course.subtitle = subtitle
        course.summary = summary
        course.location = location
        course.lecturers = Set(lecturers)
        course.semesters = Set(semesters)
        return course
    }
}
