//
//  ChangeCache.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import FileProvider
import StudKit

/// Caches changes to a data source section.
final class ChangeCache<Item: CDIdentifiable> {
    private(set) var updatedItems = [Item]()

    private(set) var deletedItemIdentifiers = [NSFileProviderItemIdentifier]()

    /// File provider sync anchor, containing a UNIX timestamp.
    private(set) var currentSyncAnchor = ChangeCache.syncAnchor()

    /// Generates a sync anchor for the date given. Defaults to now.
    private static func syncAnchor(for date: Date = Date()) -> NSFileProviderSyncAnchor {
        guard let data = String(date.timeIntervalSince1970).data(using: .utf8) else {
            fatalError("Cannot generate sync anchor data from current time.")
        }
        return NSFileProviderSyncAnchor(data)
    }

    /// Clears the cache.
    func flush() {
        updatedItems.removeAll()
        deletedItemIdentifiers.removeAll()
        currentSyncAnchor = ChangeCache.syncAnchor()
    }
}

// MARK: - Data Source Section Delegate

extension ChangeCache: DataSourceSectionDelegate {
    func data<Section: DataSourceSection>(changedIn row: Section.Row, at index: Int, change: DataChange<Section.Row, Int>,
                                          in section: Section) {
        guard let item = row as? Item else { fatalError() }
        switch change {
        case .insert, .update:
            updatedItems.append(item)
        case .delete:
            deletedItemIdentifiers.append(item.itemIdentifier)
        case .move:
            break
        }
    }
}
