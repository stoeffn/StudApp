//
//  CourseResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

struct CourseResponse: IdentifiableResponse {
    let id: String
    let number: String?
    let title: String
    let subtitle: String?
    let location: String?
    let summary: String?
    let groupId: Int
    let lecturers: Set<UserResponse>
    let beginSemesterId: String?
    let endSemesterId: String?

    init(id: String, number: String? = nil, title: String = "", subtitle: String? = nil, location: String? = nil,
         summary: String? = nil, groupId: Int = 0, lecturers: Set<UserResponse> = [],
         beginSemesterId: String? = nil, endSemesterId: String? = nil) {
        self.id = id
        self.number = number
        self.title = title
        self.subtitle = subtitle
        self.location = location
        self.summary = summary
        self.groupId = groupId
        self.lecturers = lecturers
        self.beginSemesterId = beginSemesterId
        self.endSemesterId = endSemesterId
    }
}

// MARK: - Coding

extension CourseResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "course_id"
        case number
        case title
        case subtitle
        case location
        case summary = "description"
        case groupId = "group"
        case lecturers
        case beginSemesterId = "start_semester"
        case endSemesterId = "end_semester"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawLecturers = try container.decodeIfPresent([String: UserResponse].self, forKey: .lecturers)
        id = try container.decode(String.self, forKey: .id)
        number = StudIp.transform(courseNumber: try container.decodeIfPresent(String.self, forKey: .number))
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)?.nilWhenEmpty
        location = StudIp.transform(location: try container.decodeIfPresent(String.self, forKey: .location))
        summary = StudIp.transform(courseSummary: try container.decodeIfPresent(String.self, forKey: .summary))
        groupId = try container.decodeIfPresent(Int.self, forKey: .groupId) ?? 0
        lecturers = rawLecturers.map { Set($0.values) } ?? []
        beginSemesterId = StudIp.transform(idPath: try container.decodeIfPresent(String.self, forKey: .beginSemesterId))
        endSemesterId = StudIp.transform(idPath: try container.decodeIfPresent(String.self, forKey: .endSemesterId))
    }
}

// MARK: - Converting to a Core Data Object

extension CourseResponse {
    @discardableResult
    func coreDataObject(organization: Organization, in context: NSManagedObjectContext) throws -> Course {
        let (course, _) = try Course.fetch(byId: id, orCreateIn: context)
        let beginSemester = try Semester.fetch(byId: beginSemesterId, in: context)
        let endSemester = try Semester.fetch(byId: endSemesterId, in: context)
        let semesters = try Semester.fetch(from: beginSemester, to: endSemester, in: context)
        let lecturers = try self.lecturers.map { try $0.coreDataObject(organization: organization, in: context) }
        course.organization = organization
        course.number = number
        course.title = title
        course.subtitle = subtitle
        course.summary = summary
        course.groupId = groupId
        course.location = location
        course.lecturers = Set(lecturers)
        course.semesters = Set(semesters)
        return course
    }
}
