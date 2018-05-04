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
import CoreSpotlight
import MobileCoreServices
import QuickLook

@objc(File)
public final class File: NSManagedObject, CDCreatable, CDIdentifiable, CDSortable {

    // MARK: Location Types

    /// Describes where the content of a file is stored.
    ///
    /// - invalid: Invalid configuration or inaccessible content.
    /// - studIp: Content can be retrieved via the _Stud.IP_ API.
    /// - external: Content is hosted by an external file provider.
    /// - website: Link to a web page.
    @objc
    public enum Location: Int {
        case invalid, studIp, external, website
    }

    // MARK: Identification

    public static let entity = ObjectIdentifier.Entites.file

    @NSManaged public var id: String

    /// File name including a file extension as selected by the owner. You may want to use `title` in user interfaces
    /// as it does not include the file name extension.
    @NSManaged public var name: String

    /// Uniform type identifier for this file, chosen by the system based on the file name's extension.
    @NSManaged public var typeIdentifier: String

    // MARK: Specifying Location

    /// Course this file belongs to.
    @NSManaged public var course: Course

    @NSManaged private var externalUrlString: String?

    /// When stored at an external file hoster, this property describes the remote content location.
    ///
    /// - Remark: `externalUrlString` is not of type `URI` in order to support iOS 10.
    public var externalUrl: URL? {
        get {
            guard let externalUrlString = externalUrlString else { return nil }
            guard let url = URL(string: externalUrlString) else { fatalError("Cannot construct URL from `externalUrlString`.") }
            return url
        }
        set { externalUrlString = newValue?.absoluteString }
    }

    /// Describes where the content of a file is stored.
    @NSManaged public var location: Location

    /// Parent file, which should be a folder and contain this file. If a file has no parent folder, it is assumed to be in its
    /// course's root.
    @NSManaged public var parent: File?

    @NSManaged public var organization: Organization

    // MARK: Managing Content

    /// Size of the file in bytes.
    ///
    /// - Warning: Due to Core Data restrictions, this property cannot be optional. Thus, it uses `-1` as an invalid state, e.g.
    ///            for folders.
    @NSManaged public var size: Int

    /// Files contained in this file in case of a folder.
    @NSManaged public var children: Set<File>

    // MARK: Tracking Usage

    @NSManaged public var createdAt: Date

    @NSManaged public var isNew: Bool

    @NSManaged public var modifiedAt: Date

    // MARK: Managing Metadata

    /// Number of times this file was downloaded from the server.
    ///
    /// - Warning: Due to Core Data restrictions, this property cannot be optional. Thus, it uses `-1` as an invalid state, e.g.
    ///            for folders.
    @NSManaged public var downloadCount: Int

    @NSManaged public var downloadedBy: Set<User>

    /// User who uploaded or modified this file. Might be `nil` for folders or some documents authored by multiple users.
    @NSManaged public var owner: User?

    @NSManaged public var state: FileState

    /// File description.
    @NSManaged public var summary: String?

    // MARK: - Life Cycle

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)
        state = FileState(createIn: context)
    }

    public override func prepareForDeletion() {
        try? removeDownload()
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id]) { _ in }
        super.prepareForDeletion()
    }

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:))),
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
}

// MARK: - Utilities

public extension File {
    /// Whether this file should be treated as a folder that can contain other files.
    public var isFolder: Bool {
        return typeIdentifier == kUTTypeFolder as String
    }

    /// File name without extension.
    public var title: String {
        return URL(string: name)?
            .deletingPathExtension()
            .lastPathComponent ?? name
    }

    /// Whether this file is available for download, ignoring network connectivity conditions. May also be `true` for downloaded
    /// files if a more recent version is available.
    public var isDownloadable: Bool {
        return !isFolder
            && !state.isMostRecentVersionDownloaded
            && !state.isDownloading
            && location != .invalid
    }

    /// Whether this file is available. Returns `true` for folders as they can be enumerated and for documents iff downloaded
    /// or network is available.
    public var isAvailable: Bool {
        guard location != .invalid else { return false }
        let reachabilityService = ServiceContainer.default[ReachabilityService.self]
        return (isFolder && state.childFilesUpdatedAt != nil)
            || state.isDownloaded
            || reachabilityService.currentFlags.contains(.reachable)
    }

    public var isLocationSecure: Bool {
        switch location {
        case .invalid: return false
        case .studIp: return true
        case .external: return !["http", "ftp"].contains(externalUrl?.scheme)
        case .website: return false
        }
    }

    public func localUrl(in directory: BaseDirectories) -> URL {
        return directory.containerUrl(forObjectId: objectIdentifier)
            .appendingPathComponent(name, isDirectory: isFolder)
    }

    @available(iOSApplicationExtension 11.0, *)
    public var itemProvider: NSItemProvider? {
        guard
            !isFolder && state.isDownloaded,
            let itemProvider = NSItemProvider(contentsOf: localUrl(in: .downloads))
        else { return nil }
        itemProvider.suggestedName = name
        return itemProvider
    }
}

// MARK: - Core Spotlight and Activity Tracking

extension File {
    public var keywords: Set<String> {
        let fileKeywords = [title, name, owner?.givenName, owner?.familyName].compactMap { $0 }
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

    public var userActivity: NSUserActivity {
        let activity = NSUserActivity(type: .document)
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
