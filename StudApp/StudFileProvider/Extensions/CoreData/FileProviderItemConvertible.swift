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

protocol FileProviderItemConvertible {
    var favoriteRank: Int { get set }
    var lastUsedDate: Date? { get set }
    var tagData: Data? { get set }

    func fileProviderItem(context: NSManagedObjectContext) throws -> NSFileProviderItem
}

extension FileProviderItemConvertible where Self: NSFetchRequestResult {
    static func fetchItemsInWorkingSet(in context: NSManagedObjectContext) throws -> [Self] {
        let predicate = NSPredicate(format: "lastUsedDate != NIL OR tagData != NIL OR favoriteRank != 0")
        return try context.fetch(fetchRequest(predicate: predicate))
    }
}
