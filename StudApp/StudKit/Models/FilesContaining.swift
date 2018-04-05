//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

import CoreData
import MobileCoreServices

public protocol FilesContaining {
    var objectIdentifier: ObjectIdentifier { get }

    var title: String { get }

    var childFilesPredicate: NSPredicate { get }

    func updateChildFiles(forced: Bool, completion: @escaping ResultHandler<Set<File>>)
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
