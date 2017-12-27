//
//  EventListViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public final class EventListViewModel: NSObject {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]

    public let course: Course

    public weak var delegate: DataSourceDelegate?

    public init(course: Course) {
        self.course = course
        super.init()

        controller.delegate = self
    }

    private(set) lazy var controller: NSFetchedResultsController<Event>
        = NSFetchedResultsController(fetchRequest: course.eventsFetchRequest,
                                     managedObjectContext: coreDataService.viewContext, sectionNameKeyPath: "daysSince1970",
                                     cacheName: nil)

    public func fetch() {
        try? controller.performFetch()
    }

    public func update(handler: (ResultHandler<Void>)? = nil) {
        coreDataService.performBackgroundTask { context in
            self.course.updateEvents(in: context) { result in
                try? context.saveWhenChanged()
                handler?(result.replacingValue(()))
            }
        }
    }

    public var nowIndexPath: IndexPath? {
        let today = Date()

        let sectionIndex = enumerated()
            .filter { $0.element >= today.startOfDay }
            .first?
            .offset
        guard let section = sectionIndex else { return nil }

        let rowIndex = controller.sections?[section].objects?
            .enumerated()
            .filter { ($0.element as? Event)?.startsAt ?? .distantPast >= today }
            .first?
            .offset
        guard let row = rowIndex else { return nil }

        return IndexPath(row: row, section: section)
    }
}

// MARK: - Data Source Section

extension EventListViewModel: DataSource {
    public typealias Section = Date

    public typealias Row = Event

    public var numberOfSections: Int {
        return controller.sections?.count ?? 0
    }

    public func numberOfRows(inSection index: Int) -> Int {
        return controller.sections?[index].numberOfObjects ?? 0
    }

    public subscript(sectionAt index: Int) -> Date {
        return controller.object(at: IndexPath(row: 0, section: index)).startsAt
    }

    public subscript(rowAt indexPath: IndexPath) -> Event {
        return controller.object(at: indexPath)
    }
}

// MARK: - Fetched Results Controller Delegate

extension EventListViewModel: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataWillChange(in: self)
    }

    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataDidChange(in: self)
    }

    public func controller(_: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex index: Int,
                           for type: NSFetchedResultsChangeType) {
        guard let section = (sectionInfo.objects?.first as? Event)?.startsAt else { fatalError() }

        switch type {
        case .insert:
            delegate?.data(changedIn: section, at: index, change: .insert, in: self)
        case .delete:
            delegate?.data(changedIn: section, at: index, change: .delete, in: self)
        case .update:
            delegate?.data(changedIn: section, at: index, change: .update(section), in: self)
        case .move:
            delegate?.data(changedIn: section, at: index, change: .move(to: index), in: self)
        }
    }

    public func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange object: Any, at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let event = object as? Event else { fatalError() }

        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            delegate?.data(changedIn: event, at: indexPath, change: .insert, in: self)
        case .delete:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: event, at: indexPath, change: .delete, in: self)
        case .update:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: event, at: indexPath, change: .update(event), in: self)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            delegate?.data(changedIn: event, at: indexPath, change: .move(to: newIndexPath), in: self)
        }
    }
}
