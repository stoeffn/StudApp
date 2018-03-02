//
//  FilesContaining.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import CoreData
import MobileCoreServices

public protocol FilesContaining {
    var objectIdentifier: ObjectIdentifier { get }

    var title: String { get }

    var childFilesPredicate: NSPredicate { get }

    func updateChildFiles(completion: @escaping ResultHandler<Set<File>>)
}

extension FilesContaining {
    public var childFilesFetchRequest: NSFetchRequest<File> {
        return File.fetchRequest(predicate: childFilesPredicate, sortDescriptors: File.defaultSortDescriptors,
                                 relationshipKeyPathsForPrefetching: ["state"])
    }

    public var childFoldersFetchRequest: NSFetchRequest<File> {
        let typePredicate = NSPredicate(format: "typeIdentifier == %@", kUTTypeFolder as String)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [childFilesPredicate, typePredicate])
        return File.fetchRequest(predicate: predicate, sortDescriptors: File.defaultSortDescriptors,
                                 relationshipKeyPathsForPrefetching: ["state"])
    }

    public var childDocumentsFetchRequest: NSFetchRequest<File> {
        let typePredicate = NSPredicate(format: "typeIdentifier != %@", kUTTypeFolder as String)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [childFilesPredicate, typePredicate])
        return File.fetchRequest(predicate: predicate, sortDescriptors: File.defaultSortDescriptors,
                                 relationshipKeyPathsForPrefetching: ["state"])
    }

    public func fetchChildFiles(in context: NSManagedObjectContext) throws -> [File] {
        return try context.fetch(childFilesFetchRequest)
    }

    public func fetchChildFolders(in context: NSManagedObjectContext) throws -> [File] {
        return try context.fetch(childFoldersFetchRequest)
    }

    public func fetchChildDocuments(in context: NSManagedObjectContext) throws -> [File] {
        return try context.fetch(childFoldersFetchRequest)
    }
}
