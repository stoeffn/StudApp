//
//  File.swift
//  StudKit
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import MobileCoreServices
import QuickLook

@objc(File)
public final class File: NSManagedObject, CDCreatable, CDIdentifiable, CDUpdatable {
    @NSManaged public var id: String
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
    @NSManaged public var name: String
    @NSManaged public var typeIdentifier: String
    @NSManaged public var title: String
    @NSManaged public var size: Int
    @NSManaged public var downloadCount: Int

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
    public static func downloadedPredicate(forSearchTerm searchTerm: String? = nil) -> NSPredicate {
        let downloadedPredicate = NSPredicate(format: "downloadedAt != NIL")

        guard
            let searchTerm = searchTerm,
            !searchTerm.isEmpty
        else { return downloadedPredicate }

        let trimmedSearchTerm = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)

        let similarTitlePredicate = NSPredicate(format: "file.title CONTAINS[cd] %@", trimmedSearchTerm)
        let similarCourseTitlePredicate = NSPredicate(format: "file.course.title CONTAINS[cd] %@", trimmedSearchTerm)
        let similarOwnerFamilyNamePredicate = NSPredicate(format: "file.owner.familyName CONTAINS[cd] %@", trimmedSearchTerm)
        let similarOwnerGivenNamePredicate = NSPredicate(format: "file.owner.givenName CONTAINS[cd] %@", trimmedSearchTerm)

        return NSCompoundPredicate(type: .and, subpredicates: [
            downloadedPredicate,
            NSCompoundPredicate(type: .or, subpredicates: [
                similarTitlePredicate, similarCourseTitlePredicate, similarOwnerFamilyNamePredicate,
                similarOwnerGivenNamePredicate,
            ]),
        ])
    }

    public static var downloadedFetchRequest: NSFetchRequest<FileState> {
        let sortDescriptors = [
            NSSortDescriptor(keyPath: \FileState.file.course.title, ascending: true),
            NSSortDescriptor(keyPath: \FileState.file.title, ascending: true),
        ]
        return FileState.fetchRequest(predicate: downloadedPredicate(), sortDescriptors: sortDescriptors,
                                      relationshipKeyPathsForPrefetching: ["file"])
    }

    public var childrenFetchRequest: NSFetchRequest<FileState> {
        let sortDescriptor = NSSortDescriptor(keyPath: \FileState.file.title, ascending: true)
        let predicate = NSPredicate(format: "file.parent == %@", self)
        return FileState.fetchRequest(predicate: predicate, sortDescriptors: [sortDescriptor],
                                      relationshipKeyPathsForPrefetching: ["file"])
    }
}

// MARK: - Utilities

public extension File {
    public var isFolder: Bool {
        return typeIdentifier == kUTTypeFolder as String
    }

    public var `extension`: String {
        let pathExtension = URL(string: name)?.pathExtension
        return pathExtension.map { ".\($0)" } ?? ""
    }

    public var sanitizedTitleWithExtension: String {
        return title.replacingOccurrences(of: ":", with: "") + `extension`
    }

    public static func localContainerUrl(forId id: String, in directory: URL) -> URL {
        let containerUrl = directory.appendingPathComponent(id, isDirectory: true)
        return containerUrl
    }

    public static func documentContainerUrl(forId id: String, inProviderDirectory: Bool = false) -> URL {
        guard #available(iOSApplicationExtension 11.0, *), inProviderDirectory else {
            return localContainerUrl(forId: id, in: ServiceContainer.default[StorageService.self].documentsUrl)
        }
        return localContainerUrl(forId: id, in: NSFileProviderManager.default.documentStorageURL)
    }

    public func localUrl(inProviderDirectory: Bool = false) -> URL {
        return File.documentContainerUrl(forId: id, inProviderDirectory: inProviderDirectory)
            .appendingPathComponent(name, isDirectory: isFolder)
    }

    public func documentController(handler: @escaping (UIDocumentInteractionController) -> Void) {
        let cacheService = ServiceContainer.default[CacheService.self]
        return cacheService.documentInteractionController(forUrl: localUrl(inProviderDirectory: true), name: title,
                                                          handler: handler)
    }
}

// MARK: - QuickLook Preview Item

extension File: QLPreviewItem {
    public var previewItemURL: URL? {
        return localUrl(inProviderDirectory: true)
    }

    public var previewItemTitle: String? {
        return title
    }
}
