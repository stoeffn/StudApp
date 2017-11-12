//
//  WorkingSetEnumerator.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import StudKit

final class WorkingSetEnumerator: NSObject, NSFileProviderEnumerator {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let itemIdentifier: NSFileProviderItemIdentifier
    private let viewModels: [WorkingSetViewModel]
    private let cache = ChangeCache<Course>()

    init(itemIdentifier: NSFileProviderItemIdentifier) {
        self.itemIdentifier = itemIdentifier

        viewModels = [
            WorkingSetViewModel(fetchRequest: Semester.workingSetFetchRequest as! NSFetchRequest<NSFetchRequestResult>),
            WorkingSetViewModel(fetchRequest: Course.workingSetFetchRequest as! NSFetchRequest<NSFetchRequestResult>),
            WorkingSetViewModel(fetchRequest: File.workingSetFetchRequest as! NSFetchRequest<NSFetchRequestResult>),
        ]

        super.init()

        for viewModel in viewModels {
            viewModel.delegate = cache
            viewModel.fetch()
        }
    }

    func invalidate() {}

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt _: NSFileProviderPage) {
        let items = viewModels
            .flatMap { $0 }
            .flatMap { try? $0.fileProviderItem(context: coreDataService.viewContext) }
        observer.didEnumerate(items)
        observer.finishEnumerating(upTo: nil)
    }

    func enumerateChanges(for observer: NSFileProviderChangeObserver, from _: NSFileProviderSyncAnchor) {
        let updatedItems = cache.updatedItems.flatMap { try? $0.fileProviderItem(context: coreDataService.viewContext) }
        observer.didUpdate(updatedItems)
        observer.didDeleteItems(withIdentifiers: cache.deletedItemIdentifiers)
        observer.finishEnumeratingChanges(upTo: cache.currentSyncAnchor, moreComing: false)
        cache.flush()
    }

    func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        completionHandler(cache.currentSyncAnchor)
    }
}
