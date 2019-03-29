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
import StudKit

/// Manages the file provider's working set, i.e. recently used files, tagged files, and favorites.
///
/// In order to display initial data, you must call `fetch()`. Changes in the view context are automatically propagated to
/// `delegate`.
///
/// - Remark: You will need a separate wokring set view model for each supported file type.
public final class WorkingSetViewModel: NSObject {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let fetchRequest: NSFetchRequest<NSFetchRequestResult>

    public weak var delegate: DataSourceSectionDelegate?

    /// Creates a new working set view model managing the data returned by the fetch request given.
    public init(fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        self.fetchRequest = fetchRequest
        super.init()

        controller.delegate = self
    }

    private(set) lazy var controller: NSFetchedResultsController
        = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataService.viewContext,
                                     sectionNameKeyPath: nil, cacheName: nil)

    /// Fetches initial data.
    public func fetch() {
        try? controller.performFetch()
    }
}

// MARK: - Data Source Section

extension WorkingSetViewModel: DataSourceSection {
    public typealias Row = FileProviderItemConvertible

    public var numberOfRows: Int {
        return controller.sections?.first?.numberOfObjects ?? 0
    }

    public subscript(rowAt index: Int) -> FileProviderItemConvertible {
        guard let object = controller.object(at: IndexPath(row: index, section: 0)) as? FileProviderItemConvertible else {
            let protocolName = String(describing: FileProviderItemConvertible.self)
            fatalError("Cannot cast fetched results controller object as '\(protocolName)'.")
        }
        return object
    }
}

// MARK: - Fetched Results Controller Delegate

extension WorkingSetViewModel: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataWillChange(in: self)
    }

    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataDidChange(in: self)
    }

    public func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange object: Any,
                           at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let fileConvertible = object as? FileProviderItemConvertible else { fatalError() }
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            delegate?.data(changedIn: fileConvertible, at: indexPath.row, change: .insert, in: self)
        case .delete:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: fileConvertible, at: indexPath.row, change: .delete, in: self)
        case .update:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: fileConvertible, at: indexPath.row, change: .update(fileConvertible), in: self)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            delegate?.data(changedIn: fileConvertible, at: indexPath.row, change: .move(to: newIndexPath.row), in: self)
        @unknown default:
            fatalError()
        }
    }
}
