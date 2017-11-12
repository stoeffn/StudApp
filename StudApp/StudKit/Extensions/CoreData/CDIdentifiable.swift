//
//  CDIdentifiable.swift
//  StudKit
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public protocol CDIdentifiable {
    var id: String { get }
}

public extension CDIdentifiable where Self: NSFetchRequestResult {
    public static func fetch(byId id: String?, in context: NSManagedObjectContext) throws -> Self? {
        guard let id = id, !id.isEmpty else { return nil }
        let predicate = NSPredicate(format: "id == %@", id)
        return try context.fetch(Self.fetchRequest(predicate: predicate)).first
    }
}

public extension CDIdentifiable where Self: NSFetchRequestResult & CDCreatable {
    public static func fetch(byId id: String?, orCreateIn context: NSManagedObjectContext) throws -> Self {
        return try fetch(byId: id, in: context) ?? Self(createIn: context)
    }
}

extension CDIdentifiable {
    public static func itemIdentifier(forId id: String) -> NSFileProviderItemIdentifier {
        let itemIdentifier = String(describing: Self.self).lowercased().appending("-").appending(id)
        return NSFileProviderItemIdentifier(rawValue: itemIdentifier)
    }

    public var itemIdentifier: NSFileProviderItemIdentifier {
        return Self.itemIdentifier(forId: id)
    }
}
