//
//  FilesContaining.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import CoreData
import MobileCoreServices

protocol FilesContaining: CVarArg { }

extension FilesContaining {
    public var childrenStatesFetchRequest: NSFetchRequest<FileState> {
        let predicate = NSPredicate(format: "file.parent == %@", self)
        return FileState.fetchRequest(predicate: predicate, sortDescriptors: FileState.defaultSortDescriptors,
                                      relationshipKeyPathsForPrefetching: ["file"])
    }

    public var childFoldersFetchRequest: NSFetchRequest<File> {
        let predicate = NSPredicate(format: "parent == %@ AND typeIdentifier == %@", self, kUTTypeFolder as String)
        return File.fetchRequest(predicate: predicate, sortDescriptors: File.defaultSortDescriptors)
    }

    public var childDocumentsFetchRequest: NSFetchRequest<File> {
        let predicate = NSPredicate(format: "parent == %@ AND typeIdentifier != %@", self, kUTTypeFolder as String)
        return File.fetchRequest(predicate: predicate, sortDescriptors: File.defaultSortDescriptors)
    }
}
