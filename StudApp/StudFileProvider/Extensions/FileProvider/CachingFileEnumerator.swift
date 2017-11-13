//
//  CachingFileEnumerator.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import FileProvider

open class CachingFileEnumerator: NSObject {
    public let itemIdentifier: NSFileProviderItemIdentifier
    public let coreDataService = ServiceContainer.default[CoreDataService.self]
    public let cache = ChangeCache()

    public init(itemIdentifier: NSFileProviderItemIdentifier) {
        self.itemIdentifier = itemIdentifier

        super.init()

        cache.dataDidChange = {
            NSFileProviderManager.default.signalEnumerator(for: self.itemIdentifier) { _ in }
        }
    }

    open var items: [NSFileProviderItem] { return [] }
}

// MARK: - File Provider Enumerator Conformance

extension CachingFileEnumerator: NSFileProviderEnumerator {
    public func invalidate() {}

    public func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt _: NSFileProviderPage) {
        observer.didEnumerate(items)
        observer.finishEnumerating(upTo: nil)
    }

    public func enumerateChanges(for observer: NSFileProviderChangeObserver, from _: NSFileProviderSyncAnchor) {
        let updatedItems = cache.updatedItems.flatMap { try? $0.fileProviderItem(context: coreDataService.viewContext) }
        observer.didUpdate(updatedItems)
        observer.didDeleteItems(withIdentifiers: cache.deletedItemIdentifiers)
        observer.finishEnumeratingChanges(upTo: cache.currentSyncAnchor, moreComing: false)
        cache.flush()
    }

    public func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        completionHandler(cache.currentSyncAnchor)
    }
}
