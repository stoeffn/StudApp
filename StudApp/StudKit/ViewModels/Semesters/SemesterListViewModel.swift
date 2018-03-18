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

    public private(set) lazy var fetchedResultControllerDelegateHelper = FetchedResultsControllerDelegateHelper(delegate: self)
    public weak var delegate: DataSourceSectionDelegate?

    public let organization: Organization
    public let respectsHiddenStates: Bool

    public init(organization: Organization, respectsHiddenStates: Bool = true) {
        self.organization = organization
        self.respectsHiddenStates = respectsHiddenStates

        controller.delegate = fetchedResultControllerDelegateHelper
    }

    public private(set) lazy var controller: NSFetchedResultsController<SemesterState> = NSFetchedResultsController(
        fetchRequest: respectsHiddenStates ? organization.visibleSemesterStatesFetchRequest : organization.semesterStatesFetchRequest,
        managedObjectContext: coreDataService.viewContext, sectionNameKeyPath: nil, cacheName: nil)

    public func row(from object: SemesterState) -> Semester {
        return object.semester
    }

    public func object(from row: Semester) -> SemesterState {
        return row.state
    }

    /// Fetches initial data.
    public func fetch() {
        try? controller.performFetch()
    }

    /// Updates data from the server.
    public func update(completion: (() -> Void)? = nil) {
        coreDataService.performBackgroundTask { context in
            self.organization.in(context)
                .updateSemesters { _ in DispatchQueue.main.async { completion?() } }
        }
    }
}
