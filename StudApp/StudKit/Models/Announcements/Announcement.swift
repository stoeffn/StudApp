//
//  Announcement.swift
//  StudKit
//
//  Created by Steffen Ryll on 15.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
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

    @NSManaged public var body: String

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
