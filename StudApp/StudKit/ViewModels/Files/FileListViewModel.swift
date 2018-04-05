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

/// Manages a list of files in the course or folder given. In case of a course, it manages its root files.
///
/// In order to display initial data, you must call `fetch()`. Changes in the view context are automatically propagated to
/// `delegate`. This class also supports updating data from the server.
public final class FileListViewModel: FetchedResultsControllerDataSourceSection {
    public typealias Row = File

    private let coreDataService = ServiceContainer.default[CoreDataService.self]

    public private(set) lazy var fetchedResultControllerDelegateHelper = FetchedResultsControllerDelegateHelper(delegate: self)
    public weak var delegate: DataSourceSectionDelegate?

    public let container: FilesContaining & NSManagedObject

    /// Creates a new file list view model for the given folder's contents.
    public init(container: FilesContaining & NSManagedObject) {
        self.container = container

        controller.delegate = fetchedResultControllerDelegateHelper
    }

    public private(set) lazy var controller: NSFetchedResultsController<File> = NSFetchedResultsController(
        fetchRequest: container.childFilesFetchRequest, managedObjectContext: coreDataService.viewContext,
        sectionNameKeyPath: nil, cacheName: nil)

    /// Updates data from the server.
    public func update(forced: Bool = false, completion: (() -> Void)? = nil) {
        coreDataService.performBackgroundTask { context in
            self.container.in(context)
                .updateChildFiles(forced: forced) { _ in DispatchQueue.main.async { completion?() } }
        }
    }
}
