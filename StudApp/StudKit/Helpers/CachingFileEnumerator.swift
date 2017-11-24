//
//  CachingFileEnumerator.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import FileProvider

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
open class CachingFileEnumerator: NSObject {
    public let coreDataService = ServiceContainer.default[CoreDataService.self]
    public let historyService = ServiceContainer.default[HistoryService.self]
    public let cache = ChangeCache()

    // MARK: - Providing Items

    /// File items to be enumerated, including any changed items. Defaults to none and should thus be overridden.
    open var items: [NSFileProviderItem] {
        return []
    }
}

// MARK: - File Provider Enumerator Conformance

extension CachingFileEnumerator: NSFileProviderEnumerator {
    // MARK: Enumerating Items and Changes

    public func invalidate() {}

    public func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt _: NSFileProviderPage) {
        coreDataService.viewContext.performAndWait {
            try? historyService.mergeHistory(into: self.coreDataService.viewContext)
            try? historyService.deleteHistory(mergedInto: Targets.iOSTargets, in: self.coreDataService.viewContext)

            observer.didEnumerate(items)
            observer.finishEnumerating(upTo: nil)
        }
    }

    public func enumerateChanges(for observer: NSFileProviderChangeObserver, from _: NSFileProviderSyncAnchor) {
        coreDataService.viewContext.performAndWait {
            try? historyService.mergeHistory(into: self.coreDataService.viewContext)
            try? historyService.deleteHistory(mergedInto: Targets.iOSTargets, in: self.coreDataService.viewContext)

            let updatedItems = self.cache.updatedItems
                .flatMap { try? $0.fileProviderItem(context: self.coreDataService.viewContext) }

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
