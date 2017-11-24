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

    @NSManaged public var lecturedCourses: Set<Course>
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

    public var isCurrent: Bool {
        let storageService = ServiceContainer.default[StorageService.self]
        return id == storageService.defaults.string(forKey: UserDefaults.currentUserIdKey)
    }

    public func makeCurrent() {
        let storageService = ServiceContainer.default[StorageService.self]
        storageService.defaults.set(id, forKey: UserDefaults.currentUserIdKey)
    }
}

// MARK: - Core Data Operations

extension User {
    static func fetchCurrent(in context: NSManagedObjectContext) throws -> User? {
        let storageService = ServiceContainer.default[StorageService.self]
        guard let currentUserId = storageService.defaults.string(forKey: UserDefaults.currentUserIdKey) else { return nil }
        return try fetch(byId: currentUserId, in: context)
    }
}
