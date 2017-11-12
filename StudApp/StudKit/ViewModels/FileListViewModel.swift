//
//  FileListViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public final class FileListViewModel: NSObject {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let fileService = ServiceContainer.default[FileService.self]
    private let containingId: String
    private let fetchRequest: NSFetchRequest<File>

    public weak var delegate: DataSourceSectionDelegate?

    public init(containingId: String, fetchRequest: NSFetchRequest<File>) {
        self.containingId = containingId
        self.fetchRequest = fetchRequest
        super.init()

        controller.delegate = self
    }

    private(set) lazy var controller: NSFetchedResultsController<File>
        = NSFetchedResultsController(fetchRequest: self.fetchRequest, managedObjectContext: coreDataService.viewContext,
                                     sectionNameKeyPath: nil, cacheName: nil)

    public func fetch() {
        try? controller.performFetch()
    }

    public func update(handler: @escaping ResultHandler<Void>) {
        coreDataService.performBackgroundTask { context in
            self.fileService.update(fileWithId: self.containingId, in: context) { result in
                try? context.saveWhenChanged()
                handler(result.replacingValue(()))
            }
        }
    }
}

// MARK: - Data Source Section

extension FileListViewModel: DataSourceSection {
    public typealias Row = File

    public var numberOfRows: Int {
        return controller.fetchedObjects?.count ?? 0
    }

    public subscript(rowAt index: Int) -> File {
        return controller.object(at: IndexPath(row: index, section: 0))
    }
}

// MARK: - Fetched Results Controller Delegate

extension FileListViewModel: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataWillChange(in: self)
    }

    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataDidChange(in: self)
    }

    public func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange object: Any,
                           at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let file = object as? File else { fatalError() }
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            delegate?.data(changedIn: file, at: indexPath.row, change: .insert, in: self)
        case .delete:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: file, at: indexPath.row, change: .delete, in: self)
        case .update:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: file, at: indexPath.row, change: .update(file), in: self)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            delegate?.data(changedIn: file, at: indexPath.row, change: .move(to: newIndexPath.row), in: self)
        }
    }
}
