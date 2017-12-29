//
//  EventListViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public final class EventListViewModel: FetchedResultsControllerDataSource {
    public typealias Section = Date

    public typealias Row = Event

    private let coreDataService = ServiceContainer.default[CoreDataService.self]

    lazy var fetchedResultControllerDelegateHelper = FetchedResultsControllerDelegateHelper(delegate: self)

    public weak var delegate: DataSourceDelegate?

    public let course: Course

    public init(course: Course) {
        self.course = course

        controller.delegate = fetchedResultControllerDelegateHelper
    }

    private(set) lazy var controller: NSFetchedResultsController<Event>
        = NSFetchedResultsController(fetchRequest: course.eventsFetchRequest,
                                     managedObjectContext: coreDataService.viewContext, sectionNameKeyPath: "daysSince1970",
                                     cacheName: nil)

    func section(from sectionInfo: NSFetchedResultsSectionInfo) -> Section? {
        return (sectionInfo.objects?.first as? Event)?.startsAt.startOfDay
    }

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

    public func sectionIndex(for date: Date) -> Int? {
        return controller.sections?.index { self.section(from: $0) == date.startOfDay }
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
        guard let row = rowIndex else { return IndexPath(row: 0, section: section) }

        return IndexPath(row: row, section: section)
    }
}
