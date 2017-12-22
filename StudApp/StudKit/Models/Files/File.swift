//
//  File.swift
//  StudKit
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import CoreSpotlight
import MobileCoreServices
import QuickLook

@objc(File)
public final class File: NSManagedObject, CDCreatable, CDIdentifiable, CDUpdatable, CDSortable {
    @NSManaged public var id: String

    @NSManaged public var createdAt: Date

    @NSManaged public var modifiedAt: Date

    /// Internal file name including a file extension as selected by the owner. You may want to use `title` in user interfaces
    /// as it is more human-readable.
    @NSManaged public var name: String

    /// Uniform type identifier for this file, chosen by the system based on the file name's extension.
    @NSManaged public var typeIdentifier: String

    /// Custom title, which you may prefer over `name` in user interfaces as it is human-readable.
    @NSManaged public var title: String

    /// Size of the file in bytes.
    ///
    /// - Warning: Due to Core Data restrictions, this property cannot be optional. Thus, it uses `-1` as an invalid state, e.g.
    ///            for folders.
    @NSManaged public var size: Int

    /// Number of times this file was donwloaded from the server.
    ///
    /// - Warning: Due to Core Data restrictions, this property cannot be optional. Thus, it uses `-1` as an invalid state, e.g.
    ///            for folders.
    @NSManaged public var downloadCount: Int

    /// Course this file belongs to.
    @NSManaged public var course: Course

    /// Parent file, which should be a folder and contain this file. If a file has no parent folder, it is assumed to be in its
    /// course's root.
    @NSManaged public var parent: File?

    /// User who uploaded or modified this file. Might be `nil` for folders or some documents authored by multiple users.
    @NSManaged public var owner: User?

    /// Files contained in this file in case of a folder.
    @NSManaged public var children: Set<File>

    @NSManaged public var state: FileState

    // MARK: - Life Cycle

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)
        state = FileState(createIn: context)
    }

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \File.title, ascending: true),
    ]
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
        ] + FileState.defaultSortDescriptors
        return FileState.fetchRequest(predicate: downloadedPredicate(), sortDescriptors: sortDescriptors,
                                      relationshipKeyPathsForPrefetching: ["file"])
    }

    public var childrenFetchRequest: NSFetchRequest<FileState> {
        let predicate = NSPredicate(format: "file.parent == %@", self)
        return FileState.fetchRequest(predicate: predicate, sortDescriptors: FileState.defaultSortDescriptors,
                                      relationshipKeyPathsForPrefetching: ["file"])
    }
}

// MARK: - Utilities

public extension File {
    /// Whether this file should be treated as a folder that can contain other files.
    public var isFolder: Bool {
        return typeIdentifier == kUTTypeFolder as String
    }

    /// File name extension as retrieved from the internal file name.
    public var `extension`: String {
        let pathExtension = URL(string: name)?.pathExtension.nilWhenEmpty
        return pathExtension.map { ".\($0)" } ?? ""
    }

    /// Human-readable file title with extension that only contains valid file name characters.
    public var sanitizedTitleWithExtension: String {
        return title
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: ":", with: "—")
            + `extension`
    }

    /// URL of local directory that should contain the downloaded file based on the document base directory given.
    ///
    /// - Parameters:
    ///   - id: File identifier.
    ///   - directory: Base document directory.
    public static func localContainerUrl(forId id: String, in directory: URL) -> URL {
        // TODO: Rename
        return directory.appendingPathComponent(id, isDirectory: true)
    }

    /// URL of local directory that should contain the downloaded file.
    ///
    /// - Parameters:
    ///   - id: File identifier.
    ///   - inProviderDirectory: Whether to return the local URL inside the file provider documents folder or the app's
    ///                          document folder, which is the default option. Before iOS 11, this method always uses the
    ///                          app's document folder.
    public static func documentContainerUrl(forId id: String, inProviderDirectory: Bool = false) -> URL {
        guard #available(iOSApplicationExtension 11.0, *), inProviderDirectory else {
            return localContainerUrl(forId: id, in: ServiceContainer.default[StorageService.self].documentsUrl)
        }
        return localContainerUrl(forId: id, in: NSFileProviderManager.default.documentStorageURL)
    }

    /// URL for the locally downloaded file.
    ///
    /// - Parameter inProviderDirectory: Whether to return the local file URL inside the file provider documents folder or the
    ///                                  app's document folder, which is the default option. Before iOS 11, this method always
    ////                                 uses the app's document folder.
    public func localUrl(inProviderDirectory: Bool = false) -> URL {
        return File.documentContainerUrl(forId: id, inProviderDirectory: inProviderDirectory)
            .appendingPathComponent(name, isDirectory: isFolder)
    }

    public func documentController(handler: @escaping (UIDocumentInteractionController) -> Void) {
        let cacheService = ServiceContainer.default[CacheService.self]
        return cacheService.documentInteractionController(forUrl: localUrl(inProviderDirectory: true), name: title,
                                                          handler: handler)
    }

    public var attributes: CSSearchableItemAttributeSet {
        let attributes = CSSearchableItemAttributeSet(itemContentType: typeIdentifier)
        attributes.relatedUniqueIdentifier = id
        attributes.identifier = id
        attributes.metadataModificationDate = state.downloadedAt
        attributes.kind = File.typeIdentifier
        attributes.displayName = title
        attributes.subject = title
        attributes.title = title
        attributes.keywords = keywords.array
        attributes.fileSize = size > 0 ? size as NSNumber : nil
        attributes.contentURL = localUrl(inProviderDirectory: true)
        attributes.comment = description
        attributes.downloadedDate = state.downloadedAt
        attributes.contentCreationDate = createdAt
        attributes.contentModificationDate = modifiedAt
        return attributes
    }

    public var keywords: Set<String> {
        let fileKeyWords = [name, owner?.givenName, owner?.familyName].flatMap { $0 }.set
        return fileKeyWords.union(course.keywords)
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
