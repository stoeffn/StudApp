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
    public var itemState: FileProviderItemConvertibleState {
        return state
    }

    public func fileProviderItem(context _: NSManagedObjectContext) throws -> NSFileProviderItem {
        return try FileItem(from: self)
    }
}
