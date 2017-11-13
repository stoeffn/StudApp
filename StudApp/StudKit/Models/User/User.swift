//
//  User.swift
//  StudKit
//
//  Created by Steffen Ryll on 07.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(User)
public final class User: NSManagedObject, CDCreatable, CDIdentifiable, CDUpdatable {
    @NSManaged public var id: String
    @NSManaged public var username: String
    @NSManaged public var givenName: String
    @NSManaged public var familyName: String
    @NSManaged public var namePrefix: String?
    @NSManaged public var nameSuffix: String?
    @NSManaged public var pictureModificationDate: Date?
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
