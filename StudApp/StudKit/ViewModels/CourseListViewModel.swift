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

    private var courses = [Course]()

    public weak var delegate: DataSourceSectionDelegate?

    public override init() {
        super.init()
        controller.delegate = self
    }

    private(set) lazy var controller: NSFetchedResultsController<Course>
        = NSFetchedResultsController(fetchRequest: Course.fetchRequest(), managedObjectContext: coreDataService.viewContext,
                                     sectionNameKeyPath: nil, cacheName: nil)

    func update(handler: @escaping ResultHandler<Void>) {
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
        return courses.count
    }

    public subscript(rowAt index: Int) -> Course {
        return courses[index]
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

    public func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange _: Any,
                           at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            let course = controller.object(at: indexPath)
            courses.insert(course, at: indexPath.row)
            delegate?.data(changedIn: course, at: indexPath.row, change: .insert, in: self)
        case .delete:
            guard let indexPath = indexPath else { return }
            let course = courses.remove(at: indexPath.row)
            delegate?.data(changedIn: course, at: indexPath.row, change: .delete, in: self)
        case .update:
            guard let indexPath = indexPath else { return }
            let course = controller.object(at: indexPath)
            courses[indexPath.row] = course
            delegate?.data(changedIn: course, at: indexPath.row, change: .update(course), in: self)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            let course = courses.remove(at: indexPath.row)
            courses.insert(course, at: newIndexPath.row)
            delegate?.data(changedIn: course, at: indexPath.row, change: .move(to: newIndexPath.row), in: self)
        }
    }
}
