//
//  AnnouncementListViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 19.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public final class AnnouncementListViewModel: FetchedResultsControllerDataSourceSection {
    public typealias Row = Announcement

    private let coreDataService = ServiceContainer.default[CoreDataService.self]

    lazy var fetchedResultControllerDelegateHelper = FetchedResultsControllerDelegateHelper(delegate: self)

    public let course: Course

    public weak var delegate: DataSourceSectionDelegate?

    public init(course: Course) {
        self.course = course

        controller.delegate = fetchedResultControllerDelegateHelper
    }

    private(set) lazy var controller: NSFetchedResultsController<Announcement> = NSFetchedResultsController(
        fetchRequest: course.unexpiredAnnouncementsFetchRequest, managedObjectContext: coreDataService.viewContext,
        sectionNameKeyPath: nil, cacheName: nil)

    public func update(handler: (ResultHandler<[Announcement]>)? = nil) {
        coreDataService.performBackgroundTask { context in
            self.course.updateAnnouncements(in: context) { result in
                try? context.saveWhenChanged()
                handler?(result)
            }
        }
    }
}
