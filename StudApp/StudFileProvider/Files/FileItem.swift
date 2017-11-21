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
    // MARK: - Constants

    private static let realFilenameUserInfoKey = "realFilename"

    // MARK: - Life Cycle

    init(from file: File, parentItemIdentifier: NSFileProviderItemIdentifier) {
        itemIdentifier = file.itemIdentifier
        filename = file.title
        typeIdentifier = file.typeIdentifier
        capabilities = file.isFolder ? [.allowsReading, .allowsContentEnumerating] : [.allowsReading]

        childItemCount = file.children.count as NSNumber
        documentSize = file.size >= 0 ? file.size as NSNumber : nil

        self.parentItemIdentifier = parentItemIdentifier

        contentModificationDate = file.modificationDate
        creationDate = file.creationDate
        lastUsedDate = file.state.lastUsedDate

        versionIdentifier = file.state.downloadDate?.description.data(using: .utf8)
        isMostRecentVersionDownloaded = file.state.isMostRecentVersionDownloaded

        isDownloaded = file.state.isDownloaded

        ownerNameComponents = file.owner?.nameComponents

        tagData = file.state.tagData
        favoriteRank = !file.state.isUnranked ? file.state.favoriteRank as NSNumber : nil

        super.init()

        realFilename = file.name
    }

    convenience init(from file: File) throws {
        let parentIdentifier = file.parent?.itemIdentifier ?? file.course.itemIdentifier
        self.init(from: file, parentItemIdentifier: parentIdentifier)
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

    let isDownloaded: Bool

    // MARK: Sharing

    let isShared = true

    let ownerNameComponents: PersonNameComponents?

    // MARK: Managing Metadata

    let tagData: Data?

    let favoriteRank: NSNumber?

    var userInfo: [AnyHashable: Any]? = [:]

    // MARK: Additional Properties

    /// File name on file system level.
    ///
    /// `File` has both a name and a title. The name is, as one would expect, the name at file system level, whereas the title
    /// is a simplified display name, often containing additional or more human-readable information. As `filename` on
    /// `NSFileProviderItem` refers to the display name, it contains the title of a `File`.
    var realFilename: String? {
        get { return userInfo?[FileItem.realFilenameUserInfoKey] as? String }
        set { userInfo?[FileItem.realFilenameUserInfoKey] = newValue }
    }
}
