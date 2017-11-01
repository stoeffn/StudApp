//
//  NSMangedObjectContext+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 10.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public extension NSManagedObjectContext {
    func saveWhenChanged() throws {
        if hasChanges {
            try save()
        }
    }
}
