//
//  Organization.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(Organization)
public final class Organization: NSManagedObject, CDCreatable, CDIdentifiable, CDSortable {

    // MARK: Identification

    public static let entity = ObjectIdentifier.Entites.organization

    @NSManaged public var id: String

    @NSManaged public var title: String

    // MARK: Managing API Access

    /// Remark: - This is not of type `URI` in order to support iOS 10.
    @NSManaged public var apiUrl: String

    // MARK: Managing Content

    @NSManaged public var announcements: Set<Announcement>

    @NSManaged public var courses: Set<Course>

    @NSManaged public var events: Set<Event>

    @NSManaged public var files: Set<File>

    @NSManaged public var semesters: Set<Semester>

    @NSManaged public var users: Set<User>

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \Organization.title, ascending: true),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<Organization id: \(id), title: \(title)>"
    }
}

// MARK: - Persisting Credentials

extension Organization {
    enum KeychainKeys: String {
        case consumerKey, consumerSecret
    }

    var consumerKey: String? {
        get {
            let keychainService = ServiceContainer.default[KeychainService.self]
            return try? keychainService.password(for: objectIdentifier.rawValue, account: KeychainKeys.consumerKey.rawValue)
        }
        set {
            let keychainService = ServiceContainer.default[KeychainService.self]
            guard let newValue = newValue else {
                try? keychainService.delete(from: objectIdentifier.rawValue, account: KeychainKeys.consumerKey.rawValue)
                return
            }
            try? keychainService.save(password: newValue, for: objectIdentifier.rawValue, account: KeychainKeys.consumerKey.rawValue)
        }
    }

    var consumerSecret: String? {
        get {
            let keychainService = ServiceContainer.default[KeychainService.self]
            return try? keychainService.password(for: objectIdentifier.rawValue, account: KeychainKeys.consumerSecret.rawValue)
        }
        set {
            let keychainService = ServiceContainer.default[KeychainService.self]
            guard let newValue = newValue else {
                try? keychainService.delete(from: objectIdentifier.rawValue, account: KeychainKeys.consumerSecret.rawValue)
                return
            }
            try? keychainService.save(password: newValue, for: objectIdentifier.rawValue, account: KeychainKeys.consumerSecret.rawValue)
        }
    }
}
