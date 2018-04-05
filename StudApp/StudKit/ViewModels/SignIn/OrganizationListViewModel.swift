//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
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

    @objc public private(set) dynamic var isUpdating = false

    @objc public private(set) dynamic var error: Error?

    // MARK: - Providing and Updating Data

    public private(set) lazy var fetchedResultControllerDelegateHelper = FetchedResultsControllerDelegateHelper(delegate: self)

    public weak var delegate: DataSourceSectionDelegate?

    public private(set) lazy var controller: NSFetchedResultsController<Organization> = NSFetchedResultsController(
        fetchRequest: Organization.fetchRequest(sortDescriptors: Organization.defaultSortDescriptors),
        managedObjectContext: coreDataService.viewContext, sectionNameKeyPath: nil, cacheName: nil)

    public func update() {
        guard !isUpdating else { return }

        isUpdating = true
        error = nil

        coreDataService.performBackgroundTask { context in
            Organization.update(in: context) { result in
                try? context.saveAndWaitWhenChanged()
                self.isUpdating = false
                self.error = result.error

                Organization.updateIconThumbnails(in: self.coreDataService.viewContext) { _ in
                    try? self.coreDataService.viewContext.saveAndWaitWhenChanged()
                }
            }
        }
    }
}
