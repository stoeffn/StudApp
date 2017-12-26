//
//  AnnouncementListViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 19.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public final class AnnouncementListViewModel: NSObject {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]

    public let course: Course

    public weak var delegate: DataSourceSectionDelegate?

    public init(course: Course) {
        self.course = course
        super.init()

        controller.delegate = self
    }

    private(set) lazy var controller: NSFetchedResultsController<Announcement>
        = NSFetchedResultsController(fetchRequest: course.unexpiredAnnouncementsFetchRequest,
                                     managedObjectContext: coreDataService.viewContext, sectionNameKeyPath: nil, cacheName: nil)

    public func fetch() {
        try? controller.performFetch()
    }

    public func update(handler: (ResultHandler<Void>)? = nil) {
        coreDataService.performBackgroundTask { context in
            self.course.updateAnnouncements(in: context) { result in
                try? context.saveWhenChanged()
                handler?(result.replacingValue(()))
            }
        }
    }
}

// MARK: - Data Source Section

extension AnnouncementListViewModel: DataSourceSection {
    public typealias Row = Announcement

    public var numberOfRows: Int {
        return controller.sections?.first?.numberOfObjects ?? 0
    }

    public subscript(rowAt index: Int) -> Announcement {
        return controller.object(at: IndexPath(row: index, section: 0))
    }
}

// MARK: - Fetched Results Controller Delegate

extension AnnouncementListViewModel: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataWillChange(in: self)
    }

    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataDidChange(in: self)
    }

    public func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange object: Any,
                           at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let announcement = object as? Announcement else { fatalError() }
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            delegate?.data(changedIn: announcement, at: indexPath.row, change: .insert, in: self)
        case .delete:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: announcement, at: indexPath.row, change: .delete, in: self)
        case .update:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: announcement, at: indexPath.row, change: .update(announcement), in: self)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            delegate?.data(changedIn: announcement, at: indexPath.row, change: .move(to: newIndexPath.row), in: self)
        }
    }
}
