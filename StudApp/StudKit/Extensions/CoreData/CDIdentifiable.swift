//
//  CDIdentifiable.swift
//  StudKit
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

/// Something, usually a core data managed object, that can be uniquely identified.
public protocol CDIdentifiable: ByTypeNameIdentifiable {
    /// Identifier that uniquely identifies this object.
    var id: String { get }
}

// MARK: - Utilities

public extension CDIdentifiable where Self: NSFetchRequestResult {
    /// Fetches an object by the identifier given.
    ///
    /// - Parameters:
    ///   - id: Identifier to search for.
    ///   - context: Managed object context.
    /// - Returns: Object if found, `nil` otherwise.
    public static func fetch(byId id: String?, in context: NSManagedObjectContext) throws -> Self? {
        guard
            let id = id,
            !id.isEmpty
        else { return nil }

        let predicate = NSPredicate(format: "id == %@", id)
        return try context.fetch(Self.fetchRequest(predicate: predicate)).first
    }
}

public extension CDIdentifiable where Self: NSFetchRequestResult & CDCreatable {
    /// Fetches an object by the identifier given. If there is no match, a new object will be created.
    ///
    /// - Parameters:
    ///   - id: Identifier to search for.
    ///   - context: Managed object context.
    /// - Returns: Tuple containing the object and a boolean indicating whether it was newly created during this operation.
    static func fetch(byId id: String, orCreateIn context: NSManagedObjectContext) throws -> (Self, isNew: Bool) {
        let result = try fetch(byId: id, in: context).map { ($0, isNew: false) }
        return result ?? (Self(createIn: context), isNew: true)
    }
}

extension CDIdentifiable {
    /// Creates a file provider item identifier for this object type with the identifier given.
    ///
    /// - Parameter id: Identifier to include in the item identifier.
    /// - Returns: Item identifier with the format `{lowercase type name} + "-" + {identifier}`.
    public static func itemIdentifier(forId id: String) -> NSFileProviderItemIdentifier {
        let itemIdentifier = typeIdentifier.lowercased().appending("-").appending(id)
        return NSFileProviderItemIdentifier(rawValue: itemIdentifier)
    }

    /// File provider item identifier for this object. The item identifier has the format
    /// `{lowercase type name} + "-" + {identifier}`.
    public var itemIdentifier: NSFileProviderItemIdentifier {
        return Self.itemIdentifier(forId: id)
    }
}
