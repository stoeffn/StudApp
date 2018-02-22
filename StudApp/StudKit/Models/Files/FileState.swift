//
//  FileState.swift
//  StudKit
//
//  Created by Steffen Ryll on 13.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(FileState)
public final class FileState: NSManagedObject, CDCreatable, CDSortable {

    // MARK: Specifying Location

    @NSManaged public var file: File

    // MARK: Tracking Usage

    @NSManaged public var lastUsedAt: Date?

    // MARK: Managing Metadata

    @NSManaged public var favoriteRank: Int

    @NSManaged public var tagData: Data?

    // MARK: Managing State

    @NSManaged public var downloadedAt: Date?

    @NSManaged public var isDownloading: Bool

    // MARK: - Life Cycle

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)

        favoriteRank = fileProviderFavoriteRankUnranked
    }

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \FileState.file.name, ascending: true),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<FileState: \(file)>"
    }
}

// MARK: - Utilites

public extension FileState {
    public var isDownloaded: Bool {
        return downloadedAt != nil
    }

    public var isMostRecentVersionDownloaded: Bool {
        guard let downloadedAt = downloadedAt else { return false }
        return downloadedAt >= file.modifiedAt
    }
}
