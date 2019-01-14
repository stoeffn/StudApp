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
import FileProvider
import StudKit

/// Enumerates any file items, e.g. courses, documents, or folders, returned by `items` and handles caching changed items until
/// asked to enumerate those changes.
///
/// When asked to enumerate items, this class uses those returned by `items` after merging Core Data persistent history into the
/// view context.
///
/// Enumerating changes works similarly: History is merged first. Then, it enumerates updates and deletes contained in `cache`
/// and resets the cache. Caching is needed because the system asks for changes on its own, triggered by signaling the
/// enumerator.
///
/// In order for this to work, you need to inform `cache` about any changes to the enumerator's content.
///
/// - Remark: This class is not generic so it can implement an Objective C protocol.
open class CachingFileProviderEnumerator: NSObject {
    public let coreDataService = ServiceContainer.default[CoreDataService.self]
    public let historyService = ServiceContainer.default[PersistentHistoryService.self]
    public let cache = FileProviderEnumeratorChangeCache()

    // MARK: - Providing Items

    /// File items to be enumerated, including any changed items. Defaults to none and should thus be overridden.
    open var items: [NSFileProviderItem] {
        return []
    }
}

// MARK: - File Provider Enumerator Conformance

extension CachingFileProviderEnumerator: NSFileProviderEnumerator {
    // MARK: Enumerating Items and Changes

    public func invalidate() {}

    public func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt _: NSFileProviderPage) {
        coreDataService.viewContext.performAndWait {
            try? self.historyService.mergeHistory(into: self.coreDataService.viewContext)
            try? self.historyService.deleteHistory(mergedInto: Targets.iOSTargets, in: self.coreDataService.viewContext)

            observer.didEnumerate(self.items)
            observer.finishEnumerating(upTo: nil)
        }
    }

    public func enumerateChanges(for observer: NSFileProviderChangeObserver, from _: NSFileProviderSyncAnchor) {
        coreDataService.viewContext.performAndWait {
            try? self.historyService.mergeHistory(into: self.coreDataService.viewContext)
            try? self.historyService.deleteHistory(mergedInto: Targets.iOSTargets, in: self.coreDataService.viewContext)

            let updatedItems = self.cache.updatedItems.compactMap { $0.fileProviderItem }

            observer.didUpdate(updatedItems)
            observer.didDeleteItems(withIdentifiers: self.cache.deletedItemIdentifiers)
            observer.finishEnumeratingChanges(upTo: self.cache.currentSyncAnchor, moreComing: false)

            self.cache.flush()
        }
    }

    public func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        completionHandler(cache.currentSyncAnchor)
    }
}
