//
//  FileItem.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 16.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import StudKit

/// Represents a document or folder item.
final class FileItem: NSObject, NSFileProviderItem {

    // MARK: - Life Cycle

    init(from file: File, childItemCount: Int?, parentItemIdentifier: NSFileProviderItemIdentifier) {
        itemIdentifier = NSFileProviderItemIdentifier(rawValue: file.objectIdentifier.rawValue)
        filename = file.name
        typeIdentifier = file.typeIdentifier
        capabilities = file.isFolder
            ? [.allowsReading, .allowsContentEnumerating]
            : [.allowsReading]

        self.childItemCount = childItemCount as NSNumber?
        documentSize = file.size >= 0 ? file.size as NSNumber : nil

        self.parentItemIdentifier = parentItemIdentifier

        contentModificationDate = file.modifiedAt
        creationDate = file.createdAt
        lastUsedDate = file.state.lastUsedAt

        versionIdentifier = file.state.downloadedAt?.description.data(using: .utf8)
        isMostRecentVersionDownloaded = file.state.isMostRecentVersionDownloaded

        isDownloading = file.state.isDownloading
        isDownloaded = file.state.isDownloaded

        ownerNameComponents = file.owner?.nameComponents

        tagData = file.state.tagData
        favoriteRank = !file.state.isUnranked ? file.state.favoriteRank as NSNumber : nil

        super.init()
    }

    convenience init(from file: File) {
        let childItemCount = file.state.childFilesUpdatedAt != nil
            ? try? file.managedObjectContext?.count(for: file.childFilesFetchRequest) ?? 0
            : nil
        let parentObjectIdentifier = file.parent?.objectIdentifier ?? file.course.objectIdentifier
        let parentItemIdentifier = NSFileProviderItemIdentifier(rawValue: parentObjectIdentifier.rawValue)
        self.init(from: file, childItemCount: childItemCount, parentItemIdentifier: parentItemIdentifier)
    }

    // MARK: - File Provider Item Conformance

    // MARK: Required Properties

    let itemIdentifier: NSFileProviderItemIdentifier

    /// File display name.
    ///
    /// - Remark: For the file system level name, please see `realFilename`.
    let filename: String

    let typeIdentifier: String

    let capabilities: NSFileProviderItemCapabilities

    // MARK: Managing Content

    let childItemCount: NSNumber?

    let documentSize: NSNumber?

    // MARK: Specifying Content Location

    let parentItemIdentifier: NSFileProviderItemIdentifier

    // MARK: Tracking Usage

    let contentModificationDate: Date?

    let creationDate: Date?

    let lastUsedDate: Date?

    // MARK: Tracking Versions

    let versionIdentifier: Data?

    let isMostRecentVersionDownloaded: Bool

    // MARK: Monitoring File Transfers

    let isUploaded = true

    let isDownloading: Bool

    let isDownloaded: Bool

    // MARK: Sharing

    let isShared = true

    let ownerNameComponents: PersonNameComponents?

    // MARK: Managing Metadata

    let tagData: Data?

    let favoriteRank: NSNumber?
}
