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

@objc(Semester)
public final class Semester: NSManagedObject, CDCreatable, CDIdentifiable, CDSortable {

    // MARK: Identifications

    public static let entity = ObjectIdentifier.Entites.semester

    @NSManaged public var id: String

    @NSManaged public var title: String

    // MARK: Specifying Location

    @NSManaged public var organization: Organization

    @NSManaged public var courses: Set<Course>

    // MARK: Managing Timing

    @NSManaged public var beginsAt: Date

    @NSManaged public var endsAt: Date

    @NSManaged public var coursesBeginAt: Date

    @NSManaged public var coursesEndAt: Date

    // MARK: Managing Metadata

    @NSManaged public var summary: String?

    @NSManaged public var state: SemesterState

    // MARK: - Life Cycle

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)
        state = SemesterState(createIn: context)
    }

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \Semester.beginsAt, ascending: false),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<Semester id: \(id), title: \(title)>"
    }
}

// MARK: - Utilities

public extension Semester {
    public var isCurrent: Bool {
        let now = Date()
        return now >= beginsAt && now <= endsAt
    }
}
