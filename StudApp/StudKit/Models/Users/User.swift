//
//  User.swift
//  StudKit
//
//  Created by Steffen Ryll on 07.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(User)
public final class User: NSManagedObject, CDCreatable, CDIdentifiable, CDUpdatable, CDSortable {
    public static var entity = ObjectIdentifier.Entites.user

    @NSManaged public var id: String

    @NSManaged public var username: String

    @NSManaged public var givenName: String

    @NSManaged public var familyName: String

    @NSManaged public var namePrefix: String?

    @NSManaged public var nameSuffix: String?

    @NSManaged public var pictureModifiedAt: Date?

    @NSManaged public var createdAnnouncements: Set<Announcement>

    @NSManaged public var lecturedCourses: Set<Course>

    @NSManaged public var ownedFiles: Set<File>

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \User.username, ascending: true),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<User id: \(id), username: \(username)>"
    }
}

// MARK: - Utilities

public extension User {
    public var nameComponents: PersonNameComponents {
        var components = PersonNameComponents()
        components.givenName = givenName
        components.familyName = familyName
        components.namePrefix = namePrefix
        components.nameSuffix = nameSuffix
        return components
    }
}
