//
//  Announcement.swift
//  StudKit
//
//  Created by Steffen Ryll on 15.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(Announcement)
public final class Announcement: NSManagedObject, CDCreatable, CDIdentifiable, CDUpdatable, CDSortable {
    public static var entity = ObjectIdentifier.Entites.announcement

    @NSManaged public var id: String

    @NSManaged public var title: String

    @NSManaged public var createdAt: Date

    @NSManaged public var modifiedAt: Date

    @NSManaged public var expiresAt: Date

    @NSManaged public var body: String

    @NSManaged public var courses: Set<Course>

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \Announcement.createdAt, ascending: false),
    ]
}
