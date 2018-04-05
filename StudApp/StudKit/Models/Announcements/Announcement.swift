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

@objc(Announcement)
public final class Announcement: NSManagedObject, CDCreatable, CDIdentifiable, CDSortable {

    // MARK: Identification

    public static let entity = ObjectIdentifier.Entites.announcement

    @NSManaged public var id: String

    @NSManaged public var title: String

    // MARK: Specifying Location

    @NSManaged public var courses: Set<Course>

    @NSManaged public var organization: Organization

    // MARK: Tracking Usage and Expiry

    @NSManaged public var createdAt: Date

    @NSManaged public var modifiedAt: Date

    @NSManaged public var expiresAt: Date

    // MARK: Managing Content and Ownership

    @NSManaged public var htmlContent: String

    @NSManaged public var textContent: String

    @NSManaged public var user: User?

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \Announcement.createdAt, ascending: false),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<Announcement id: \(id), courses: \(courses), title: \(title)>"
    }
}
