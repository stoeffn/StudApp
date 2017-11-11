//
//  File+FileProviderItemConvertible.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import StudKit

extension File: FileProviderItemConvertible {
    func fileProviderItem(context: NSManagedObjectContext) throws -> NSFileProviderItem {
        return FolderItem(from: self, childItemCount: 42)
    }
}
