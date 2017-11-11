//
//  CourseEnumerator.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class CourseEnumerator: NSObject, NSFileProviderEnumerator {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let itemIdentifier: NSFileProviderItemIdentifier
    private let viewModel: CourseListViewModel
    private let cache = ChangeCache<Course>()

    init(itemIdentifier: NSFileProviderItemIdentifier) {
        self.itemIdentifier = itemIdentifier

        guard let semester = try? Semester.fetch(byId: itemIdentifier.id, in: coreDataService.viewContext),
            let unwrappedSemester = semester else { fatalError() }

        viewModel = CourseListViewModel(fetchRequest: unwrappedSemester.coursesFetchRequest)
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
        for index in 0...viewModel.numberOfRows - 1 {
            if let item = try? viewModel[rowAt: index].fileProviderItem(context: coreDataService.viewContext) {
                observer.didEnumerate([item])
            }
        }
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
