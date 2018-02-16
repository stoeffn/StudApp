//
//  CDUpdatable.swift
//  StudKit
//
//  Created by Steffen Ryll on 27.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

/// Something that can be updated in Core Data.
protocol CDUpdatable: CDIdentifiable {}

// MARK: - Default Implementation

extension CDUpdatable where Self: NSManagedObject {
    static func update<Value, Values: Sequence>(_ existingObjectsFetchRequest: NSFetchRequest<Self>? = nil,
                                                with values: Values, in context: NSManagedObjectContext,
                                                transform: (Value) throws -> Self) throws -> [Self] where Values.Element == Value {
        let existingObjectsFetchRequest = existingObjectsFetchRequest ?? Self.fetchRequest(predicate: NSPredicate(value: false))
        existingObjectsFetchRequest.propertiesToFetch = ["id"]

        let existingObjects = try context.fetch(existingObjectsFetchRequest)
        let existingIds = existingObjects.map { $0.id }

        let updatedObjects = try values.map(transform)
        let updatedIds = updatedObjects.map { $0.id }

        let deletedIds = Set(existingIds).subtracting(updatedIds)
        let deletedObjects = existingObjects.filter { deletedIds.contains($0.id) }
        deletedObjects.forEach(context.delete)

        return updatedObjects
    }
}
