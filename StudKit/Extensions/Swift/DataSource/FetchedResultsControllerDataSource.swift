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

public protocol FetchedResultsControllerDataSource: FetchedResultsControllerSource, DataSource, FetchedResultsControllerDelegate {
    var delegate: DataSourceDelegate? { get }

    func section(from sectionInfo: NSFetchedResultsSectionInfo) -> Section?
}

public extension FetchedResultsControllerDataSource {
    func controller(didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        let section = self.section(from: sectionInfo)

        switch type {
        case .insert:
            delegate?.data(changedIn: section, at: sectionIndex, change: .insert, in: self)
        case .delete:
            delegate?.data(changedIn: section, at: sectionIndex, change: .delete, in: self)
        case .update:
            delegate?.data(changedIn: section, at: sectionIndex, change: .update(section), in: self)
        case .move:
            delegate?.data(changedIn: section, at: sectionIndex, change: .move(to: sectionIndex), in: self)
        }
    }

    func controller(didChange object: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        guard let object = object as? Object else { fatalError() }
        let row = self.row(from: object)

        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            delegate?.data(changedIn: row, at: indexPath, change: .insert, in: self)
        case .delete:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: row, at: indexPath, change: .delete, in: self)
        case .update:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: row, at: indexPath, change: .update(row), in: self)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            delegate?.data(changedIn: row, at: indexPath, change: .move(to: newIndexPath), in: self)
        }
    }

    func controllerWillChangeContent() {
        delegate?.dataWillChange(in: self)
    }

    func controllerDidChangeContent() {
        delegate?.dataDidChange(in: self)
    }
}

public extension FetchedResultsControllerDataSource {
    var numberOfSections: Int {
        return controller.sections?.count ?? 0
    }

    func numberOfRows(inSection index: Int) -> Int {
        return controller.sections?[index].numberOfObjects ?? 0
    }

    var numberOfRows: Int {
        return controller.sections?
            .reduce(0) { $0 + $1.numberOfObjects } ?? 0
    }

    func index(for indexPath: IndexPath) -> Int {
        let indexUntilSection = controller.sections?
            .prefix(upTo: indexPath.section)
            .reduce(0) { $0 + $1.numberOfObjects } ?? 0
        return indexUntilSection + indexPath.row
    }

    subscript(sectionAt index: Int) -> Section {
        guard
            let sectionInfo = controller.sections?[index],
            let section = section(from: sectionInfo)
        else { fatalError() }
        return section
    }

    subscript(rowAt indexPath: IndexPath) -> Row {
        return row(from: controller.object(at: indexPath))
    }

    subscript(rowAt index: Int) -> Row {
        var index = index

        for section in 0 ..< numberOfSections {
            guard index < numberOfRows(inSection: section) else {
                index -= numberOfRows(inSection: section)
                continue
            }

            let indexPath = IndexPath(row: index, section: section)
            return row(from: controller.object(at: indexPath))
        }

        fatalError("Invalid index: \(index)")
    }

    func indexPath(for row: Row) -> IndexPath? {
        return controller.indexPath(forObject: object(from: row))
    }

    var sectionIndexTitles: [String]? {
        return controller.sectionIndexTitles
    }

    func section(forSectionIndexTitle title: String, at index: Int) -> Int {
        return controller.section(forSectionIndexTitle: title, at: index)
    }
}
