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

import FileProvider
import StudKit

/// Caches changes to a data source section.
public class FileProviderEnumeratorChangeCache {
    public private(set) var updatedItems = [CDIdentifiable & FileProviderItemConvertible]()

    public private(set) var deletedItemIdentifiers = [NSFileProviderItemIdentifier]()

    /// File provider sync anchor, containing a UNIX timestamp.
    public private(set) var currentSyncAnchor = FileProviderEnumeratorChangeCache.syncAnchor()

    public init() {}

    /// Generates a sync anchor for the date given. Defaults to now.
    private static func syncAnchor(for date: Date = Date()) -> NSFileProviderSyncAnchor {
        guard let data = String(date.timeIntervalSince1970).data(using: .utf8) else {
            fatalError("Cannot generate sync anchor data from current time.")
        }
        return NSFileProviderSyncAnchor(data)
    }

    /// Clears the cache.
    public func flush() {
        updatedItems.removeAll()
        deletedItemIdentifiers.removeAll()
        currentSyncAnchor = FileProviderEnumeratorChangeCache.syncAnchor()
    }
}

// MARK: - Data Source Section Delegate

extension FileProviderEnumeratorChangeCache: DataSourceSectionDelegate {
    public func data<Section: DataSourceSection>(changedIn row: Section.Row, at _: Int, change: DataChange<Section.Row, Int>,
                                                 in _: Section) {
        guard let item = row as? CDIdentifiable & FileProviderItemConvertible else { fatalError() }
        switch change {
        case .insert, .update:
            updatedItems.append(item)
        case .delete:
            let itemIdentifier = NSFileProviderItemIdentifier(rawValue: item.objectIdentifier.rawValue)
            deletedItemIdentifiers.append(itemIdentifier)
        case .move:
            break
        }
    }
}
