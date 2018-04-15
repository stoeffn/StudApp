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
            : (file.isLocationSecure ? [.allowsReading] : [])

        self.childItemCount = childItemCount as NSNumber?
        documentSize = file.size > 0 ? file.size as NSNumber : nil

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
