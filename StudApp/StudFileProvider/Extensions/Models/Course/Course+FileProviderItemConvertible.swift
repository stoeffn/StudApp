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
    var state: FileProviderItemConvertibleState {
        return self.state
    }

    func fileProviderItem(context _: NSManagedObjectContext) throws -> NSFileProviderItem {
        return CourseItem(from: self, childItemCount: 42)
    }
}
