//
//  File.swift
//  StudKit
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import MobileCoreServices
import CoreData

@objc(File)
public final class File: NSManagedObject, CDCreatable, CDIdentifiable, CDUpdatable {
    @NSManaged public var id: String
    @NSManaged public var creationDate: Date
    @NSManaged public var modificationDate: Date
    @NSManaged public var name: String
    @NSManaged public var typeIdentifier: String
    @NSManaged public var title: String
    @NSManaged public var size: Int
    @NSManaged public var numberOfDownloads: Int

    @NSManaged public var course: Course
    @NSManaged public var parent: File?
    @NSManaged public var owner: User?
    @NSManaged public var children: Set<File>
    @NSManaged public var state: FileState

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)
        state = FileState(createIn: context)
    }
}

// MARK: - Core Data Operations

extension File {
    public static var downloadedFetchRequest: NSFetchRequest<FileState> {
        let predicate = NSPredicate(format: "downloadDate != NIL")
        let sortDescriptors = [
            NSSortDescriptor(keyPath: \FileState.file.course.title, ascending: true),
            NSSortDescriptor(keyPath: \FileState.file.title, ascending: true),
        ]
        return FileState.fetchRequest(predicate: predicate, sortDescriptors: sortDescriptors,
                                      relationshipKeyPathsForPrefetching: ["file"])
    }

    public var childrenFetchRequest: NSFetchRequest<File> {
        let predicate = NSPredicate(format: "parent == %@", self)
        return File.fetchRequest(predicate: predicate, relationshipKeyPathsForPrefetching: ["state"])
    }
}

// MARK: - Utilities

public extension File {
    public static func localContainerUrl(forId id: String) -> URL {
        let storageService = ServiceContainer.default[StorageService.self]
        return storageService.documentsUrl
            .appendingPathComponent(id, isDirectory: true)
    }

    public var isFolder: Bool {
        return typeIdentifier == kUTTypeFolder as String
    }

    public var localUrl: URL {
        return File.localContainerUrl(forId: id)
            .appendingPathComponent(name, isDirectory: false)
    }
}

// TODO: Move to StudIp group
extension File {
    @discardableResult
    public func download(handler: @escaping ResultHandler<URL>) -> URLSessionTask {
        let studIp = ServiceContainer.default[StudIpService.self]
        return studIp.api.download(.fileContents(forFileId: id), to: localUrl, handler: handler)
    }

    public func removeDownload() throws {
        state.downloadDate = nil
        try FileManager.default.removeItem(at: localUrl)
        try managedObjectContext?.saveWhenChanged()
    }
}
