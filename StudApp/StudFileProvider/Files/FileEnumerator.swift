//
//  FileEnumerator.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import StudKit

final class FileEnumerator: NSObject, NSFileProviderEnumerator {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let itemIdentifier: NSFileProviderItemIdentifier
    private let viewModel: FileListViewModel
    private let cache = ChangeCache<File>()

    init(itemIdentifier: NSFileProviderItemIdentifier) {
        self.itemIdentifier = itemIdentifier

        guard let fetchRequest = try? FileEnumerator.fetchRequest(forChildrenInItemWithIdentifier: itemIdentifier,
                                                                  context: coreDataService.viewContext),
            let unwrappedFetchRequest = fetchRequest else { fatalError() }

        viewModel = FileListViewModel(fetchRequest: unwrappedFetchRequest)
        super.init()

        viewModel.delegate = cache
        viewModel.fetch()
        viewModel.update { result in
            if result.isSuccess {
                NSFileProviderManager.default.signalEnumerator(for: self.itemIdentifier) { _ in }
            }
        }
    }

    private static func fetchRequest(forChildrenInItemWithIdentifier identifier: NSFileProviderItemIdentifier,
                                     context: NSManagedObjectContext) throws -> NSFetchRequest<File>? {
        switch identifier.modelType {
        case let .course(id):
            return try Course.fetch(byId: id, in: context)?.rootFilesFetchRequest
        case let .file(id):
            return try File.fetch(byId: id, in: context)?.childrenFetchRequest
        default:
            fatalError("Cannot fetch files in item with identifier \(identifier).")
        }
    }

    func invalidate() {}

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt _: NSFileProviderPage) {
        let items = viewModel.flatMap { try? $0.fileProviderItem(context: coreDataService.viewContext) }
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
