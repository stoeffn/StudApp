//
//  OrganizationListViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public final class OrganizationListViewModel: FetchedResultsControllerDataSourceSection {
    public typealias Row = Organization

    private let coreDataService = ServiceContainer.default[CoreDataService.self]

    public private(set) lazy var fetchedResultControllerDelegateHelper = FetchedResultsControllerDelegateHelper(delegate: self)

    public weak var delegate: DataSourceSectionDelegate?

    public init() {
        controller.delegate = fetchedResultControllerDelegateHelper
    }

    public private(set) lazy var controller: NSFetchedResultsController<Organization> = NSFetchedResultsController(
        fetchRequest: Organization.fetchRequest(), managedObjectContext: coreDataService.viewContext,
        sectionNameKeyPath: nil, cacheName: nil)

    public func update(completion: (ResultHandler<Void>)? = nil) {
        coreDataService.performBackgroundTask { context in
            Organization.update(in: context) { result in
                try? context.saveAndWaitWhenChanged()
                completion?(result.map { _ in () })
            }
        }
    }
}
