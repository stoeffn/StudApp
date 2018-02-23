//
//  SemesterResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

struct SemesterResponse: IdentifiableResponse {
    let id: String
    let title: String
    let beginsAt: Date
    let endsAt: Date
    let coursesBeginAt: Date
    let coursesEndAt: Date
    let summary: String?

    init(id: String, title: String = "", beginsAt: Date = .distantPast, endsAt: Date = .distantPast,
         coursesBeginAt: Date = .distantPast, coursesEndAt: Date = .distantPast, summary: String? = nil) {
        self.id = id
        self.title = title
        self.beginsAt = beginsAt
        self.endsAt = endsAt
        self.coursesBeginAt = coursesBeginAt
        self.coursesEndAt = coursesEndAt
        self.summary = summary
    }
}

// MARK: - Coding

extension SemesterResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case beginsAt = "begin"
        case endsAt = "end"
        case coursesBeginAt = "seminars_begin"
        case coursesEndAt = "seminars_end"
        case summary = "description"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        beginsAt = try container.decode(Date.self, forKey: .beginsAt)
        endsAt = try container.decode(Date.self, forKey: .endsAt)
        coursesBeginAt = try container.decode(Date.self, forKey: .coursesBeginAt)
        coursesEndAt = try container.decode(Date.self, forKey: .coursesEndAt)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)?.nilWhenEmpty
    }
}

// MARK: - Converting to a Core Data Object

extension SemesterResponse {
    @discardableResult
    func coreDataObject(organization: Organization, in context: NSManagedObjectContext) throws -> Semester {
        let (semester, isNew) = try Semester.fetch(byId: id, orCreateIn: context)
        semester.organization = organization
        semester.title = title
        semester.beginsAt = beginsAt
        semester.endsAt = endsAt
        semester.coursesBeginAt = coursesBeginAt
        semester.coursesEndAt = coursesEndAt
        semester.summary = summary
        semester.state.isHidden = isNew ? !semester.isCurrent : semester.state.isHidden
        return semester
    }
}
