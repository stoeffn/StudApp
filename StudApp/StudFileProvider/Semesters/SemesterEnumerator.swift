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
    private let changeTracker = ChangeTracker<Semester>()

    init(itemIdentifier: NSFileProviderItemIdentifier) {
        self.itemIdentifier = itemIdentifier
        super.init()

        viewModel.delegate = changeTracker
        viewModel.fetch()
    }

    func invalidate() {}

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        let items = viewModel.semesters.flatMap { try? SemesterItem(from: $0) }
        observer.didEnumerate(items)
        observer.finishEnumerating(upTo: nil)
    }

    func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {
        let updatedItems = changeTracker.updatedItems.flatMap { try? SemesterItem(from: $0) }
        observer.didUpdate(updatedItems)
        observer.didDeleteItems(withIdentifiers: changeTracker.deletedItemIdentifiers)
        observer.finishEnumeratingChanges(upTo: changeTracker.currentSyncAnchor, moreComing: false)
        changeTracker.flush()
    }
}
