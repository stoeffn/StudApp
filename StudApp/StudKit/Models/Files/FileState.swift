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
    @NSManaged public var lastUsedDate: Date?
    @NSManaged public var favoriteRank: Int
    @NSManaged public var tagData: Data?

    @NSManaged public var downloadDate: Date?

    @NSManaged public var file: File

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)

        favoriteRank = Int(NSFileProviderFavoriteRankUnranked)
    }
}

// MARK: - Utilites

public extension FileState {
    public var isDownloaded: Bool {
        return downloadDate != nil
    }

    public var isMostRecentVersionDownloaded: Bool {
        guard let downloadDate = downloadDate else { return false }
        return downloadDate >= file.modificationDate
    }
}
