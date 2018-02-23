//
//  OrganizationListViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CloudKit
import CoreData

public final class OrganizationListViewModel: NSObject, FetchedResultsControllerDataSourceSection {
    public typealias Row = Organization

    private let coreDataService = ServiceContainer.default[CoreDataService.self]

    // MARK: - Life Cycle

    public override init() {
        super.init()
        controller.delegate = fetchedResultControllerDelegateHelper
    }

    // MARK: - Managing State

    @objc public dynamic var isUpdating = false

    @objc public dynamic var error: Error?

    public var errorMessage: String? {
        switch error {
        case nil:
            return nil
        case CKError.networkUnavailable?, CKError.networkUnavailable?:
            return "There seems to be a problem with the internet connection.".localized
        default:
            return "Unfortunately, there was an internal error.".localized
        }
    }

    // MARK: - Providing and Updating Data

    public private(set) lazy var fetchedResultControllerDelegateHelper = FetchedResultsControllerDelegateHelper(delegate: self)

    public weak var delegate: DataSourceSectionDelegate?

    public private(set) lazy var controller: NSFetchedResultsController<Organization> = NSFetchedResultsController(
        fetchRequest: Organization.fetchRequest(), managedObjectContext: coreDataService.viewContext,
        sectionNameKeyPath: nil, cacheName: nil)

    public func update() {
        guard !isUpdating else { return }

        isUpdating = true
        error = nil

        coreDataService.performBackgroundTask { context in
            Organization.update(in: context) { result in
                try? context.saveAndWaitWhenChanged()
                self.isUpdating = false
                self.error = result.error
            }
        }
    }
}
