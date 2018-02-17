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
public final class File: NSManagedObject, CDCreatable, CDIdentifiable, CDSortable {
    public static var entity = ObjectIdentifier.Entites.file

    // MARK: Identification

    @NSManaged public var id: String

    /// File name including a file extension as selected by the owner. You may want to use `title` in user interfaces
    /// as it does not include the file name extension.
    @NSManaged public var name: String

    /// Uniform type identifier for this file, chosen by the system based on the file name's extension.
    @NSManaged public var typeIdentifier: String

    // MARK: Managing Content

    /// Size of the file in bytes.
    ///
    /// - Warning: Due to Core Data restrictions, this property cannot be optional. Thus, it uses `-1` as an invalid state, e.g.
    ///            for folders.
    @NSManaged public var size: Int

    /// Files contained in this file in case of a folder.
    @NSManaged public var children: Set<File>

    // MARK: Specifying Content Location

    /// Course this file belongs to.
    @NSManaged public var course: Course

    /// Parent file, which should be a folder and contain this file. If a file has no parent folder, it is assumed to be in its
    /// course's root.
    @NSManaged public var parent: File?

    // MARK: Tracking Usage

    @NSManaged public var createdAt: Date

    @NSManaged public var modifiedAt: Date

    // MARK: Managing Metadata

    /// Number of times this file was downloaded from the server.
    ///
    /// - Warning: Due to Core Data restrictions, this property cannot be optional. Thus, it uses `-1` as an invalid state, e.g.
    ///            for folders.
    @NSManaged public var downloadCount: Int

    /// File description.
    @NSManaged public var summary: String?

    /// User who uploaded or modified this file. Might be `nil` for folders or some documents authored by multiple users.
    @NSManaged public var owner: User?

    @NSManaged public var state: FileState

    // MARK: - Life Cycle

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)
        state = FileState(createIn: context)
    }

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \File.name, ascending: true),
    ]

    // MARK: - Describing

    public override var description: String {
        let type = isFolder ? "Folder" : "Document"
        return "<\(type) id: \(id), course: \(course), parent: \(parent?.description ?? "—"), title: \(title)>"
    }
}

// MARK: - Core Data Operations

extension File: FilesContaining {
    public var childFilesPredicate: NSPredicate {
        return NSPredicate(format: "course == %@ AND parent == %@", course, self)
    }

    public var childFileStatesPredicate: NSPredicate {
        return NSPredicate(format: "file.course == %@ AND file.parent == %@", course, self)
    }

    public static func downloadedPredicate(forSearchTerm searchTerm: String? = nil) -> NSPredicate {
        let downloadedPredicate = NSPredicate(format: "downloadedAt != NIL")

        guard let searchTerm = searchTerm, !searchTerm.isEmpty else { return downloadedPredicate }

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

    public static var downloadedStatesFetchRequest: NSFetchRequest<FileState> {
        let sortDescriptors = [
            NSSortDescriptor(keyPath: \FileState.file.course.title, ascending: true),
        ] + FileState.defaultSortDescriptors
        return FileState.fetchRequest(predicate: downloadedPredicate(), sortDescriptors: sortDescriptors,
                                      relationshipKeyPathsForPrefetching: ["file"])
    }
}

// MARK: - Utilities

public extension File {
    /// Whether this file should be treated as a folder that can contain other files.
    public var isFolder: Bool {
        return typeIdentifier == kUTTypeFolder as String
    }

    // TODO: Provide a lightweight alternative for retrieving icons
    public func documentController(completion: @escaping (UIDocumentInteractionController) -> Void) {
        let cacheService = ServiceContainer.default[CacheService.self]
        return cacheService.documentInteractionController(forUrl: localUrl(in: .fileProvider), name: title, completion: completion)
    }

    /// Whether this file is available for download, ignoring network connectivity conditions. May also be `true` for downloaded
    /// files if a more recent version is available.
    public var isDownloadable: Bool {
        return !isFolder
            && !state.isMostRecentVersionDownloaded
            && !state.isDownloading
    }

    /// Whether this file is available. Returns `true` for folders as they can be enumerated and for documents iff downloaded
    /// or network is available.
    public var isAvailable: Bool {
        let reachabilityService = ServiceContainer.default[ReachabilityService.self]
        return isFolder
            || state.isDownloaded
            || reachabilityService.currentReachabilityFlags.contains(.reachable)
    }

    public func localUrl(in directory: BaseDirectories) -> URL {
        return directory.containerUrl(forObjectId: objectIdentifier)
            .appendingPathComponent(name, isDirectory: isFolder)
    }

    /// File name without extension.
    public var title: String {
        return URL(string: name)?
            .deletingPathExtension()
            .lastPathComponent ?? name
    }
}

// MARK: - Core Spotlight and Activity Tracking

extension File {
    public var keywords: Set<String> {
        let fileKeywords = [owner?.givenName, owner?.familyName].flatMap { $0 }
        return Set(fileKeywords).union(course.keywords)
    }

    public var searchableItemAttributes: CSSearchableItemAttributeSet {
        let attributes = CSSearchableItemAttributeSet(itemContentType: typeIdentifier)

        attributes.displayName = title
        attributes.keywords = Array(keywords)
        attributes.relatedUniqueIdentifier = objectIdentifier.rawValue
        attributes.title = title

        // Apparently, Core Spotlight expects file sizes in mega bytes.
        attributes.contentDescription = summary
        attributes.fileSize = size > 0 ? size / 1024 / 1024 as NSNumber : nil
        attributes.identifier = id
        attributes.subject = title

        attributes.contentURL = localUrl(in: .fileProvider)
        attributes.comment = description
        attributes.downloadedDate = state.downloadedAt
        attributes.contentCreationDate = createdAt
        attributes.contentModificationDate = modifiedAt

        return attributes
    }

    public var searchableItem: CSSearchableItem {
        return CSSearchableItem(uniqueIdentifier: objectIdentifier.rawValue, domainIdentifier: File.entity.rawValue,
                                attributeSet: searchableItemAttributes)
    }

    public var searchableChildItems: [CSSearchableItem] {
        return children
            .filter { !$0.isFolder }
            .map { $0.searchableItem }
    }

    public var userActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: UserActivities.fileIdentifier)
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = true
        activity.title = title
        activity.webpageURL = url
        activity.contentAttributeSet = searchableItemAttributes
        activity.keywords = keywords
        activity.objectIdentifier = objectIdentifier
        return activity
    }
}

// MARK: - QuickLook Previewing

extension File: QLPreviewItem {
    public var previewItemURL: URL? {
        return localUrl(in: .fileProvider)
    }

    public var previewItemTitle: String? {
        return title
    }
}
