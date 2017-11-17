//
//  CachingFileEnumerator.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import FileProvider

open class CachingFileEnumerator: NSObject {
    public let itemIdentifier: NSFileProviderItemIdentifier
    public let coreDataService = ServiceContainer.default[CoreDataService.self]
    public let historyService = ServiceContainer.default[HistoryService.self]
    public let cache = ChangeCache()

    public init(itemIdentifier: NSFileProviderItemIdentifier) {
        self.itemIdentifier = itemIdentifier
    }

    open var items: [NSFileProviderItem] { return [] }

    open var fetchItems: (() -> Void)?
}

// MARK: - File Provider Enumerator Conformance

extension CachingFileEnumerator: NSFileProviderEnumerator {
    public func invalidate() {}

    public func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt _: NSFileProviderPage) {
        observer.didEnumerate(items)
        observer.finishEnumerating(upTo: nil)
    }

    public func enumerateChanges(for observer: NSFileProviderChangeObserver, from _: NSFileProviderSyncAnchor) {
        coreDataService.viewContext.performAndWait {
            historyService.mergeHistory(into: self.coreDataService.viewContext)

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
