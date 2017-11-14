//
//  FileItem.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 16.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import StudKit

final class FileItem: NSObject, NSFileProviderItem {
    let itemIdentifier: NSFileProviderItemIdentifier
    let filename: String
    let typeIdentifier: String
    let capabilities: NSFileProviderItemCapabilities
    let childItemCount: NSNumber?
    let documentSize: NSNumber?
    let parentItemIdentifier: NSFileProviderItemIdentifier
    let contentModificationDate: Date?
    let creationDate: Date?
    let lastUsedDate: Date?
    let isDownloaded: Bool
    let isMostRecentVersionDownloaded: Bool
    let tagData: Data?
    let favoriteRank: NSNumber?
    let isShared: Bool = true
    let ownerNameComponents: PersonNameComponents?

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
        isDownloaded = file.isDownloaded
        isMostRecentVersionDownloaded = file.isMostRecentVersionDownloaded
        tagData = file.state.tagData
        favoriteRank = !file.state.isUnranked ? file.state.favoriteRank as NSNumber : nil
        ownerNameComponents = file.owner?.nameComponents
    }

    convenience init(from file: File) throws {
        let parentIdentifier = file.parent?.itemIdentifier ?? file.course.itemIdentifier
        self.init(from: file, parentItemIdentifier: parentIdentifier)
    }

    convenience init(byId id: String, context: NSManagedObjectContext) throws {
        guard let file = try File.fetch(byId: id, in: context) else { throw NSFileProviderError(.noSuchItem) }
        try self.init(from: file)
    }
}
