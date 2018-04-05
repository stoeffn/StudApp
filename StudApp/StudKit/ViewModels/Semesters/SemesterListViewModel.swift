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

import CoreData

/// Manages a list of semesters.
///
/// In order to display initial data, you must call `fetch()`. Changes in the view context are automatically propagated to
/// `delegate`. This class also supports updating data from the server.
public final class SemesterListViewModel: FetchedResultsControllerDataSourceSection {
    public typealias Row = Semester

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
