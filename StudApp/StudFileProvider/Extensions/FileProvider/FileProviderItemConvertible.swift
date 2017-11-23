//
//  FileProviderItemConvertible.swift
//  StudKit
//
//  Created by Steffen Ryll on 04.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import FileProvider

/// Something that can be converted to a file provider item, e.g. a course or file.
public protocol FileProviderItemConvertible: class {
    /// Current state of this item.
    var itemState: FileProviderItemConvertibleState { get }

    /// Converts this object to a file provider item.
    /// - TODO: Use object's context.
    func fileProviderItem(context: NSManagedObjectContext) throws -> NSFileProviderItem
}

// MARK: - Operating on File Items

extension FileProviderItemConvertible where Self: NSFetchRequestResult {
    /// Request fetching all objects of this type that are in the working set, which includes recently used items, tagged items,
    /// and items marked as favorite.
    public static var workingSetFetchRequest: NSFetchRequest<Self> {
        let predicate = NSPredicate(format: "state.lastUsedDate != NIL OR state.tagData != NIL OR state.favoriteRank != %d",
                                    NSFileProviderFavoriteRankUnranked)
        return fetchRequest(predicate: predicate, relationshipKeyPathsForPrefetching: ["state"])
    }

    /// Fetches all objects of this type in the working set, which includes recently used items, tagged items, and items marked
    /// as favorite.
    public static func fetchItemsInWorkingSet(in context: NSManagedObjectContext) throws -> [Self] {
        return try context.fetch(workingSetFetchRequest)
    }
}
