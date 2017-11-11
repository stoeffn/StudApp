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

    public private(set) var semesters = [Semester]()

    public weak var delegate: DataSourceSectionDelegate?

    public override init() {
        super.init()
        controller.delegate = self
    }

    private(set) lazy var controller: NSFetchedResultsController<Semester>
        = NSFetchedResultsController(fetchRequest: Semester.fetchRequest(), managedObjectContext: coreDataService.viewContext,
                                     sectionNameKeyPath: nil, cacheName: nil)

    public func fetch() {
        try? controller.performFetch()
    }

    public func update(handler: @escaping ResultHandler<Void>) {
        coreDataService.performBackgroundTask { context in
            self.semesterService.updateSemesters(in: context) { result in
                try? context.saveWhenChanged()
                handler(result.replacingValue(()))
            }
        }
    }
}

// MARK: - Data Source Section

extension SemesterListViewModel: DataSourceSection {
    public typealias Row = Semester

    public var numberOfRows: Int {
        return semesters.count
    }

    public subscript(rowAt index: Int) -> Semester {
        return semesters[index]
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

    public func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange _: Any, at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            let semester = controller.object(at: indexPath)
            semesters.insert(semester, at: indexPath.row)
            delegate?.data(changedIn: semester, at: indexPath.row, change: .insert, in: self)
        case .delete:
            guard let indexPath = indexPath else { return }
            let semester = semesters.remove(at: indexPath.row)
            delegate?.data(changedIn: semester, at: indexPath.row, change: .delete, in: self)
        case .update:
            guard let indexPath = indexPath else { return }
            let semester = controller.object(at: indexPath)
            if indexPath.row > semesters.count - 1 {
                semesters.append(semester)
            } else {
                semesters[indexPath.row] = semester
            }
            delegate?.data(changedIn: semester, at: indexPath.row, change: .update(semester), in: self)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            let semester = semesters.remove(at: indexPath.row)
            semesters.insert(semester, at: newIndexPath.row)
            delegate?.data(changedIn: semester, at: indexPath.row, change: .move(to: newIndexPath.row), in: self)
        }
    }
}
