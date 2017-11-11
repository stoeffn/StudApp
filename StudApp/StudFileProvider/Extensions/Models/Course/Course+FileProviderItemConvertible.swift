//
//  Course+FileProviderItemConvertible.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import StudKit

extension Course: FileProviderItemConvertible {
    var itemState: FileProviderItemConvertibleState {
        return state
    }

    func fileProviderItem(context: NSManagedObjectContext) throws -> NSFileProviderItem {
        return try CourseItem(from: self, context: context)
    }
}
