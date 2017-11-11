//
//  CourseListViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 03.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public final class CourseListViewModel: NSObject {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let courseService = ServiceContainer.default[CourseService.self]
    private var fetchRequest: NSFetchRequest<Course>

    public weak var delegate: DataSourceSectionDelegate?

    public init(fetchRequest: NSFetchRequest<Course> = Course.fetchRequest()) {
        self.fetchRequest = fetchRequest
        super.init()

        controller.delegate = self
    }

    private(set) lazy var controller: NSFetchedResultsController<Course>
        = NSFetchedResultsController(fetchRequest: self.fetchRequest, managedObjectContext: coreDataService.viewContext,
                                     sectionNameKeyPath: nil, cacheName: nil)

    public func fetch() {
        try? controller.performFetch()
    }

    public func update(handler: @escaping ResultHandler<Void>) {
        coreDataService.performBackgroundTask { context in
            self.courseService.updateCourses(in: context) { result in
                handler(result.replacingValue(()))
            }
        }
    }
}

// MARK: - Data Source Section

extension CourseListViewModel: DataSourceSection {
    public typealias Row = Course

    public var numberOfRows: Int {
        return controller.fetchedObjects?.count ?? 0
    }

    public subscript(rowAt index: Int) -> Course {
        return controller.object(at: IndexPath(row: index, section: 0))
    }
}

// MARK: - Fetched Results Controller Delegate

extension CourseListViewModel: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataWillChange(in: self)
    }

    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataDidChange(in: self)
    }

    public func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange object: Any,
                           at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let course = object as? Course else { fatalError() }
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            delegate?.data(changedIn: course, at: indexPath.row, change: .insert, in: self)
        case .delete:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: course, at: indexPath.row, change: .delete, in: self)
        case .update:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: course, at: indexPath.row, change: .update(course), in: self)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            delegate?.data(changedIn: course, at: indexPath.row, change: .move(to: newIndexPath.row), in: self)
        }
    }
}
