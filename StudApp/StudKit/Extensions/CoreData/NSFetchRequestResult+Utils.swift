//
//  NSFetchRequestResult+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public extension NSFetchRequestResult {
    /// Returns a fetch request for this object, using the parameters given as its properties.
    public static func fetchRequest(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = [],
                                    limit: Int? = nil, offset: Int? = nil,
                                    refreshesRefetchedObjects: Bool = false,
                                    relationshipKeyPathsForPrefetching: [String] = []) -> NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = limit ?? request.fetchLimit
        request.fetchOffset = offset ?? request.fetchOffset
        request.shouldRefreshRefetchedObjects = refreshesRefetchedObjects
        request.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching
        return request
    }

    /// Returns an array of all objects of that type in a given context sorted by `sortDescriptors`.
    public static func fetch(in context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor] = []) throws -> [Self] {
        return try context.fetch(fetchRequest(sortDescriptors: sortDescriptors))
    }
}

public extension NSFetchRequestResult where Self: NSManagedObject {
    public func inContext(_ context: NSManagedObjectContext) -> Self {
        guard let object = context.object(with: objectID) as? Self else {
            fatalError("Cannot find object '\(self)' in context '\(context)'.")
        }
        return object
    }
}
