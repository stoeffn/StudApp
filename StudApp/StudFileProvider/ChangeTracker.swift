//
//  ChangeTracker.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import FileProvider
import StudKit

final class ChangeTracker<Item: CDIdentifiable>: DataSourceSectionDelegate {
    private(set) var updatedItems = [Item]()
    private(set) var deletedItemIdentifiers = [NSFileProviderItemIdentifier]()

    var currentSyncAnchor: NSFileProviderSyncAnchor {
        let now = Date()
        guard let data = String(now.timeIntervalSince1970).data(using: .utf8) else {
            fatalError("Cannot generate sync anchor data from current time.")
        }
        return NSFileProviderSyncAnchor(data)
    }

    func flush() {
        updatedItems.removeAll()
        deletedItemIdentifiers.removeAll()
    }

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