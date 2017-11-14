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

// MARK: - Utilities

public extension File {
    public static func localContainerUrl(forId id: String) -> URL {
        let storageService = ServiceContainer.default[StorageService.self]
        return storageService.documentsUrl
            .appendingPathComponent(id, isDirectory: true)
    }

    public static func isDownloaded(id: String) -> Bool {
        let containerPath = localContainerUrl(forId: id).path
        return FileManager.default.fileExists(atPath: containerPath)
            && !((try? FileManager.default.contentsOfDirectory(atPath: containerPath).isEmpty) ?? true)
    }

    public var isFolder: Bool {
        return typeIdentifier == kUTTypeFolder as String
    }

    public var localUrl: URL {
        return File.localContainerUrl(forId: id)
            .appendingPathComponent(name, isDirectory: false)
    }

    public var isDownloaded: Bool {
        return File.isDownloaded(id: id)
    }

    public var isMostRecentVersionDownloaded: Bool {
        guard isDownloaded,
            let localAttributes = try? FileManager.default.attributesOfItem(atPath: localUrl.path) as NSDictionary,
            let localModificationDate = localAttributes.fileModificationDate()
        else { return false }
        return localModificationDate >= modificationDate
    }
}

// MARK: - Core Data Operations

extension File {
    public var childrenFetchRequest: NSFetchRequest<File> {
        let predicate = NSPredicate(format: "parent == %@", self)
        return File.fetchRequest(predicate: predicate, relationshipKeyPathsForPrefetching: ["state"])
    }
}

// TODO: Move to service
extension File {
    @discardableResult
    public func download(handler: @escaping ResultHandler<URL>) -> Progress {
        let studIp = ServiceContainer.default[StudIpService.self]
        return studIp.api.download(.fileContents(forFileId: id), to: localUrl) { result in
            if result.isFailure {
                try? FileManager.default.removeItem(at: self.localUrl.deletingLastPathComponent())
            }
            handler(result)
        }
    }
}
