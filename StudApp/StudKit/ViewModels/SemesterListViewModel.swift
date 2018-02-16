//
//  SemesterListViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

/// Manages a list of semesters.
///
/// In order to display initial data, you must call `fetch()`. Changes in the view context are automatically propagated to
/// `delegate`. This class also supports updating data from the server.
public final class SemesterListViewModel: FetchedResultsControllerDataSourceSection {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let studIpService = ServiceContainer.default[StudIpService.self]
    private var fetchRequest: NSFetchRequest<SemesterState>

    lazy var fetchedResultControllerDelegateHelper = FetchedResultsControllerDelegateHelper(delegate: self)

    public weak var delegate: DataSourceSectionDelegate?

    /// Creates a new semester list view model managing the semesters in returned by the request given, which defaults to all
    /// semesters.
    public init(fetchRequest: NSFetchRequest<SemesterState> = Semester.statesFetchRequest) {
        self.fetchRequest = fetchRequest

        controller.delegate = fetchedResultControllerDelegateHelper
    }

    private(set) lazy var controller: NSFetchedResultsController<SemesterState> = NSFetchedResultsController(
        fetchRequest: fetchRequest, managedObjectContext: coreDataService.viewContext, sectionNameKeyPath: nil, cacheName: nil)

    func row(from object: SemesterState) -> Semester {
        return object.semester
    }

    func object(from row: Semester) -> SemesterState {
        return row.state
    }

    /// Fetches initial data.
    public func fetch() {
        try? controller.performFetch()
    }

    /// Updates data from the server.
    public func update(enforce: Bool = false, handler: ResultHandler<Void>? = nil) {
        coreDataService.performBackgroundTask { context in
            Semester.update(in: context, enforce: enforce) { result in
                try? context.saveWhenChanged()
                handler?(result.map { _ in () })
            }
        }
    }
}
