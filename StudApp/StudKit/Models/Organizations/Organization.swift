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
    enum ExternalKeys: String {
        case apiUrl, consumerKey, consumerSecret
    }

    // MARK: Identification

    public static let entity = ObjectIdentifier.Entites.organization

    @NSManaged public var id: String

    @NSManaged public var title: String

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

// MARK: Managing API Access

extension Organization {
    /// Remark: - This is not of type `URI` in order to support iOS 10.
    var apiUrl: URL? {
        get {
            willAccessValue(forKey: ExternalKeys.apiUrl.rawValue)
            defer { didAccessValue(forKey: ExternalKeys.apiUrl.rawValue) }
            guard
                let rawApiUrl = primitiveValue(forKey: ExternalKeys.apiUrl.rawValue) as? String,
                let apiUrl = URL(string: rawApiUrl)
                else { return nil }
            return apiUrl
        }
        set {
            willChangeValue(forKey: ExternalKeys.apiUrl.rawValue)
            setPrimitiveValue(newValue?.absoluteString, forKey: ExternalKeys.apiUrl.rawValue)
            didChangeValue(forKey: ExternalKeys.apiUrl.rawValue)
        }
    }
}

// MARK: - Persisting Credentials

extension Organization {
    var consumerKey: String? {
        get {
            let keychainService = ServiceContainer.default[KeychainService.self]
            return try? keychainService.password(for: objectIdentifier.rawValue, account: ExternalKeys.consumerKey.rawValue)
        }
        set {
            let keychainService = ServiceContainer.default[KeychainService.self]
            guard let newValue = newValue else {
                try? keychainService.delete(from: objectIdentifier.rawValue, account: ExternalKeys.consumerKey.rawValue)
                return
            }
            try? keychainService.save(password: newValue, for: objectIdentifier.rawValue, account: ExternalKeys.consumerKey.rawValue)
        }
    }

    var consumerSecret: String? {
        get {
            let keychainService = ServiceContainer.default[KeychainService.self]
            return try? keychainService.password(for: objectIdentifier.rawValue, account: ExternalKeys.consumerSecret.rawValue)
        }
        set {
            let keychainService = ServiceContainer.default[KeychainService.self]
            guard let newValue = newValue else {
                try? keychainService.delete(from: objectIdentifier.rawValue, account: ExternalKeys.consumerSecret.rawValue)
                return
            }
            try? keychainService.save(password: newValue, for: objectIdentifier.rawValue, account: ExternalKeys.consumerSecret.rawValue)
        }
    }
}
