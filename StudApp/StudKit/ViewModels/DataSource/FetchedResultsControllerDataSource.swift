//
//  FetchedResultsControllerDataSource.swift
//  StudKit
//
//  Created by Steffen Ryll on 29.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

protocol FetchedResultsControllerDataSource: FetchedResultsControllerSource, DataSource, FetchedResultsControllerDelegate {
    var delegate: DataSourceDelegate? { get }

    func section(from sectionInfo: NSFetchedResultsSectionInfo) -> Section

    func sectionInfo(from section: Section) -> NSFetchedResultsSectionInfo
}

extension FetchedResultsControllerDataSource {
    public func controller(didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int,
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

    public func controller(didChange object: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType,
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

    public func controllerWillChangeContent() {
        delegate?.dataWillChange(in: self)
    }

    public func controllerDidChangeContent() {
        delegate?.dataDidChange(in: self)
    }
}
