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
import MobileCoreServices

/// Announcement.
///
/// Announcements may be created by lecturers and can be associated with one or multiple courses but only one organization. They
/// can contain rich content that can be rendered as HTML but also provide a plaintext representation. Announcements also expire
/// after at a certain point of time.
@objc(Announcement)
public final class Announcement: NSManagedObject, CDCreatable, CDIdentifiable, CDSortable {
    // MARK: Identification

    public static let entity = ObjectIdentifier.Entites.announcement

    @NSManaged public var id: String

    /// The announcement's title.
    @NSManaged public var title: String

    // MARK: Specifying Location

    /// Courses this announcement should appear in.
    @NSManaged public var courses: Set<Course>

    @NSManaged public var organization: Organization

    // MARK: Tracking Usage and Expiry

    /// When this annoucement was created.
    @NSManaged public var createdAt: Date

    @NSManaged public var isNew: Bool

    /// When this annoucement was last modified.
    @NSManaged public var modifiedAt: Date

    /// When this annoucement expires. Expired annoucements should not be visible to the user.
    @NSManaged public var expiresAt: Date

    // MARK: Managing Content and Ownership

    /// Rich content that can be rendered as HTML.
    @NSManaged public var htmlContent: String

    /// Plaintext representation of `textContent`.
    @NSManaged public var textContent: String

    /// User who posted this annoucement.
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

// MARK: - Utilities

public extension Announcement {
    var itemProvider: NSItemProvider? {
        guard let data = textContent.data(using: .utf8) else { return nil }
        return NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)
    }
}
