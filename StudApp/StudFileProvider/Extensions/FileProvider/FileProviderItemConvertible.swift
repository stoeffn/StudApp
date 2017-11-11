//
//  FileProviderItemConvertible.swift
//  StudKit
//
//  Created by Steffen Ryll on 04.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import FileProvider
import StudKit

protocol FileProviderItemConvertible: class {
    var itemState: FileProviderItemConvertibleState { get }

    func fileProviderItem(context: NSManagedObjectContext) throws -> NSFileProviderItem
}

extension FileProviderItemConvertible where Self: NSFetchRequestResult {
    static func fetchItemsInWorkingSet(in context: NSManagedObjectContext) throws -> [Self] {
        let predicate = NSPredicate(format: "state.lastUsedDate != NIL OR state.tagData != NIL OR state.favoriteRank != 0")
        return try context.fetch(fetchRequest(predicate: predicate, relationshipKeyPathsForPrefetching: ["state"]))
    }
}
