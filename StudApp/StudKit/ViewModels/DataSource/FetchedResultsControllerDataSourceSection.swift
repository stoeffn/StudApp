//
//  FetchedResultsControllerDataSourceSection.swift
//  StudKit
//
//  Created by Steffen Ryll on 29.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension FetchedResultsControllerDataSourceSection {
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

protocol FetchedResultsControllerDataSourceSection: FetchedResultsControllerSource, DataSourceSection,
    FetchedResultsControllerDelegate {
    var delegate: DataSourceSectionDelegate? { get }
}

extension FetchedResultsControllerDataSourceSection {
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
