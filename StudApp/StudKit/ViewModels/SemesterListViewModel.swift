//
//  SemesterListViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public final class SemesterListViewModel: NSObject {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let semesterService = ServiceContainer.default[SemesterService.self]
    private let studIpService = ServiceContainer.default[StudIpService.self]
    private var fetchRequest: NSFetchRequest<Semester>

    public weak var delegate: DataSourceSectionDelegate?

    public init(fetchRequest: NSFetchRequest<Semester> = Semester.sortedFetchRequest) {
        self.fetchRequest = fetchRequest
        super.init()

        controller.delegate = self
    }

    private(set) lazy var controller: NSFetchedResultsController<Semester>
        = NSFetchedResultsController(fetchRequest: self.fetchRequest, managedObjectContext: coreDataService.viewContext,
                                     sectionNameKeyPath: nil, cacheName: nil)

    public func fetch() {
        try? controller.performFetch()
    }

    public func update(handler: ResultHandler<Void>? = nil) {
        coreDataService.performBackgroundTask { context in
            self.semesterService.update(in: context) { result in
                try? context.saveWhenChanged()
                handler?(result.replacingValue(()))
            }
        }
    }

    public func signOut() {
        studIpService.signOut()
    }
}

// MARK: - Data Source Section

extension SemesterListViewModel: DataSourceSection {
    public typealias Row = Semester

    public var numberOfRows: Int {
        return controller.fetchedObjects?.count ?? 0
    }

    public subscript(rowAt index: Int) -> Semester {
        return controller.object(at: IndexPath(row: index, section: 0))
    }
}

// MARK: - Fetched Results Controller Delegate

extension SemesterListViewModel: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataWillChange(in: self)
    }

    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataDidChange(in: self)
    }

    public func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange object: Any, at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let semester = object as? Semester else { fatalError() }
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            delegate?.data(changedIn: semester, at: indexPath.row, change: .insert, in: self)
        case .delete:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: semester, at: indexPath.row, change: .delete, in: self)
        case .update:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: semester, at: indexPath.row, change: .update(semester), in: self)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            delegate?.data(changedIn: semester, at: indexPath.row, change: .move(to: newIndexPath.row), in: self)
        }
    }
}
