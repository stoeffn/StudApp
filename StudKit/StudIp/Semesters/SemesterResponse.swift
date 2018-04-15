//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
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
