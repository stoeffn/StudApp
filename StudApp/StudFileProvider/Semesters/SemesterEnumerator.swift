//
//  SemesterEnumerator.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class SemesterEnumerator: NSObject, NSFileProviderEnumerator {
    private let itemIdentifier: NSFileProviderItemIdentifier
    private let viewModel = SemesterListViewModel()
    private let cache = ChangeCache<Semester>()

    init(itemIdentifier: NSFileProviderItemIdentifier) {
        self.itemIdentifier = itemIdentifier
        super.init()

        viewModel.delegate = cache
        viewModel.fetch()
        viewModel.update { result in
            if result.isSuccess {
                NSFileProviderManager.default.signalEnumerator(for: self.itemIdentifier) { _ in }
            }
        }
    }

    func invalidate() {}

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt _: NSFileProviderPage) {
        let items = viewModel.semesters.flatMap { try? SemesterItem(from: $0) }
        observer.didEnumerate(items)
        observer.finishEnumerating(upTo: nil)
    }

    func enumerateChanges(for observer: NSFileProviderChangeObserver, from _: NSFileProviderSyncAnchor) {
        let updatedItems = cache.updatedItems.flatMap { try? SemesterItem(from: $0) }
        observer.didUpdate(updatedItems)
        observer.didDeleteItems(withIdentifiers: cache.deletedItemIdentifiers)
        observer.finishEnumeratingChanges(upTo: cache.currentSyncAnchor, moreComing: false)
        cache.flush()
    }

    func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        completionHandler(cache.currentSyncAnchor)
    }
}
