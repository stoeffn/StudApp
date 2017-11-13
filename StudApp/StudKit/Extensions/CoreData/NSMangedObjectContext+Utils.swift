//
//  NSMangedObjectContext+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 10.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public extension NSManagedObjectContext {
    /// Attempts to commit unsaved changes to registered objects to the context’s parent store if there are unsaved changes.
    ///
    /// If a context’s parent store is a persistent store coordinator, then changes are committed to the external store. If a
    /// context’s parent store is another managed object context, then `save()` only updates managed objects in that parent
    /// store. To commit changes to the external store, you must save changes in the chain of contexts up to and including the
    /// context whose parent is the persistent store coordinator.
    func saveWhenChanged() throws {
        if hasChanges {
            try save()
        }
    }
}
