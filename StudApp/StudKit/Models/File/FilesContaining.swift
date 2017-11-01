//
//  FilesContaining.swift
//  StudKit
//
//  Created by Steffen Ryll on 14.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public protocol FilesContaining {
    var filesFetchRequest: NSFetchRequest<File> { get }
}

public extension FilesContaining {
    public func fetchFiles(in context: NSManagedObjectContext) throws -> [File] {
        return try context.fetch(filesFetchRequest)
    }

    public func numberOfFiles(in context: NSManagedObjectContext) throws -> Int {
        return try context.count(for: filesFetchRequest)
    }
}
