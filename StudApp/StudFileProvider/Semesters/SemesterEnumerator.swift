//
//  SemesterEnumerator.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class SemesterEnumerator: NSObject, NSFileProviderEnumerator {
    private let viewModel = SemesterListViewModel()
    private var itemIdentifier: NSFileProviderItemIdentifier

    init(itemIdentifier: NSFileProviderItemIdentifier) {
        self.itemIdentifier = itemIdentifier
        super.init()

        viewModel.fetch()
    }

    func invalidate() {

    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {

    }

    func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {

    }
}
