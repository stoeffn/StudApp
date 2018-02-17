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

    var childFileStatesPredicate: NSPredicate { get }

    func updateChildFiles(in context: NSManagedObjectContext, completion: @escaping ResultHandler<File>)
}

extension FilesContaining {
    public var childFileStatesFetchRequest: NSFetchRequest<FileState> {
        return FileState.fetchRequest(predicate: childFileStatesPredicate, sortDescriptors: FileState.defaultSortDescriptors,
                                      relationshipKeyPathsForPrefetching: ["file"])
    }

    public var childFoldersFetchRequest: NSFetchRequest<File> {
        let typePredicate = NSPredicate(format: "typeIdentifier == %@", kUTTypeFolder as String)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [childFilesPredicate, typePredicate])
        return File.fetchRequest(predicate: predicate, sortDescriptors: File.defaultSortDescriptors)
    }

    public var childDocumentsFetchRequest: NSFetchRequest<File> {
        let typePredicate = NSPredicate(format: "typeIdentifier != %@", kUTTypeFolder as String)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [childFilesPredicate, typePredicate])
        return File.fetchRequest(predicate: predicate, sortDescriptors: File.defaultSortDescriptors)
    }
}
