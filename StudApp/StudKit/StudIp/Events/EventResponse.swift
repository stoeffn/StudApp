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

struct EventResponse: IdentifiableResponse {
    let id: String
    let startsAt: Date
    let endsAt: Date
    let isCanceled: Bool
    let cancellationReason: String?
    let location: String?
    let summary: String?
    let category: String?

    init(id: String, startsAt: Date = .distantPast, endsAt: Date = .distantPast, isCanceled: Bool = false,
         cancellationReason: String? = nil, location: String? = nil, summary: String? = nil, category: String? = nil) {
        self.id = id
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.isCanceled = isCanceled
        self.cancellationReason = cancellationReason
        self.location = location
        self.summary = summary
        self.category = category
    }
}

// MARK: - Coding

extension EventResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "event_id"
        case startsAt = "start"
        case endsAt = "end"
        case isCanceled = "deleted"
        case cancellationReason = "canceled"
        case location = "room"
        case summary = "description"
        case category = "categories"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        startsAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .startsAt)
        endsAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .endsAt)
        isCanceled = try container.decodeIfPresent(Bool.self, forKey: .isCanceled) ?? false
        cancellationReason = try? container.decode(String.self, forKey: .cancellationReason)
        location = isCanceled ? nil : StudIp.transform(location: try container.decodeIfPresent(String.self, forKey: .location))
        summary = try container.decodeIfPresent(String.self, forKey: .summary)?.nilWhenEmpty
        category = try container.decodeIfPresent(String.self, forKey: .category)?.nilWhenEmpty
    }
}

// MARK: - Converting to a Core Data Object

extension EventResponse {
    @discardableResult
    func coreDataObject(course: Course, in context: NSManagedObjectContext) throws -> Event {
        let (event, _) = try Event.fetch(byId: id, orCreateIn: context)
        event.organization = course.organization
        event.course = course
        event.startsAt = startsAt
        event.endsAt = endsAt
        event.isCanceled = isCanceled
        event.cancellationReason = cancellationReason
        event.location = location
        event.summary = summary
        event.category = category
        return event
    }
}
