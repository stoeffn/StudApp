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

@objc(Event)
public final class Event: NSManagedObject, CDCreatable, CDIdentifiable, CDSortable {

    // MARK: Identification

    public static let entity = ObjectIdentifier.Entites.event

    @NSManaged public var id: String

    // MARK: Specifying Location

    @NSManaged public var course: Course

    @NSManaged public var organization: Organization

    // MARK: Managing Timing

    @NSManaged public var startsAt: Date

    @NSManaged public var endsAt: Date

    @NSManaged public var isCanceled: Bool

    @NSManaged public var cancellationReason: String?

    // MARK: Managing Metadata

    @NSManaged public var category: String?

    @NSManaged public var location: String?

    @NSManaged public var summary: String?

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \Event.startsAt, ascending: true),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<Event id: \(id), course: \(course.id)>"
    }
}

// MARK: - Utilities

extension Event {
    @objc var daysSince1970: Int {
        return startsAt.days(since: Date(timeIntervalSince1970: 0))
    }
}
