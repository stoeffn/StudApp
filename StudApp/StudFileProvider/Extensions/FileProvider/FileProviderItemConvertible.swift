//
//  FileProviderItemConvertible.swift
//  StudKit
//
//  Created by Steffen Ryll on 04.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import FileProvider

public protocol FileProviderItemConvertible: class {
    var itemState: FileProviderItemConvertibleState { get }

    func fileProviderItem(context: NSManagedObjectContext) throws -> NSFileProviderItem
}

// MARK: - Utilities

extension FileProviderItemConvertible where Self: NSFetchRequestResult {
    public static var workingSetFetchRequest: NSFetchRequest<Self> {
        let predicate = NSPredicate(format: "state.lastUsedDate != NIL OR state.tagData != NIL OR state.favoriteRank != %d",
                                    NSFileProviderFavoriteRankUnranked)
        return fetchRequest(predicate: predicate, relationshipKeyPathsForPrefetching: ["state"])
    }

    public static func fetchItemsInWorkingSet(in context: NSManagedObjectContext) throws -> [Self] {
        return try context.fetch(workingSetFetchRequest)
    }
}
