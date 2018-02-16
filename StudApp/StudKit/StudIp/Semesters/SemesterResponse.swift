//
//  SemesterResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

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

// MARK: - Converting to a Core Data Object

extension SemesterResponse {
    @discardableResult
    func coreDataObject(in context: NSManagedObjectContext) throws -> Semester {
        let (semester, isNew) = try Semester.fetch(byId: id, orCreateIn: context)
        semester.id = id
        semester.title = title
        semester.beginsAt = beginsAt
        semester.endsAt = endsAt
        semester.coursesBeginAt = coursesBeginAt
        semester.coursesEndAt = coursesEndAt
        semester.state.isHidden = isNew ? !semester.isCurrent : semester.state.isHidden
        return semester
    }
}
