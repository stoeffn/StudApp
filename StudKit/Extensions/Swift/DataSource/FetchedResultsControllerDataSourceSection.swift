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

public protocol FetchedResultsControllerDataSourceSection: FetchedResultsControllerSource, DataSourceSection,
    FetchedResultsControllerDelegate {
    var delegate: DataSourceSectionDelegate? { get }
}

public extension FetchedResultsControllerDataSourceSection {
    public func controller(didChange _: NSFetchedResultsSectionInfo, atSectionIndex _: Int,
                           for _: NSFetchedResultsChangeType) {}

    public func controller(didChange object: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        guard let object = object as? Object else { return }
        let row = self.row(from: object)

        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            delegate?.data(changedIn: row, at: indexPath.row, change: .insert, in: self)
        case .delete:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: row, at: indexPath.row, change: .delete, in: self)
        case .update:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: row, at: indexPath.row, change: .update(row), in: self)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            delegate?.data(changedIn: row, at: indexPath.row, change: .move(to: newIndexPath.row), in: self)
        }
    }

    public func controllerWillChangeContent() {
        delegate?.dataWillChange(in: self)
    }

    public func controllerDidChangeContent() {
        delegate?.dataDidChange(in: self)
    }
}

public extension FetchedResultsControllerDataSourceSection {
    public var numberOfRows: Int {
        return controller.sections?.first?.numberOfObjects ?? 0
    }

    public subscript(rowAt index: Int) -> Row {
        let object = controller.object(at: IndexPath(row: index, section: 0))
        return row(from: object)
    }

    public func index(for row: Row) -> Int? {
        return controller.indexPath(forObject: object(from: row))?.row
    }
}
