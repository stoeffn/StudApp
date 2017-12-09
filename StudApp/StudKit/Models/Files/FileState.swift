//
//  FileState.swift
//  StudKit
//
//  Created by Steffen Ryll on 13.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(FileState)
public final class FileState: NSManagedObject, CDCreatable {
    @NSManaged public var lastUsedAt: Date?
    @NSManaged public var favoriteRank: Int
    @NSManaged public var tagData: Data?

    @NSManaged public var downloadedAt: Date?
    @NSManaged public var isDownloading: Bool

    @NSManaged public var file: File

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)

        favoriteRank = defaultFavoriteRank
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
