//
//  DataSourceSectionDelegate.swift
//  StudKit
//
//  Created by Steffen Ryll on 19.09.17.
//  Copyright © 2017 Remonder. All rights reserved.
//

public protocol DataSourceSectionDelegate: class {
    func dataWillChange<Section: DataSourceSection>(in section: Section)

    func dataDidChange<Section: DataSourceSection>(in section: Section)

    func data<Section: DataSourceSection>(changedIn row: Section.Row, at index: Int, change: DataChange<Section.Row, Int>,
                                          in section: Section)
}

// MARK: - Default Implementation

public extension DataSourceSectionDelegate {
    func dataWillChange<Section: DataSourceSection>(in _: Section) {}

    func dataDidChange<Section: DataSourceSection>(in _: Section) {}

    func data<Section: DataSourceSection>(changedIn _: Section.Row, at _: Int, change _: DataChange<Section.Row, Int>,
                                          in _: Section) {}
}

// MARK: - Table View Controller Implementation

public extension DataSourceSectionDelegate where Self: UITableViewController {
    func dataWillChange<Section: DataSourceSection>(in _: Section) {
        tableView.beginUpdates()
    }

    func dataDidChange<Section: DataSourceSection>(in _: Section) {
        tableView.endUpdates()
    }

    func data<Section: DataSourceSection>(changedIn _: Section.Row, at index: Int, change: DataChange<Section.Row, Int>,
                                          in _: Section) {
        let indexPath = IndexPath(row: index, section: 0)
        switch change {
        case .insert:
            tableView.insertRows(at: [indexPath], with: .middle)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .middle)
        case .update:
            tableView.reloadRows(at: [indexPath], with: .fade)
        case let .move(newIndex):
            let newIndexPath = IndexPath(row: newIndex, section: 0)
            tableView.moveRow(at: indexPath, to: newIndexPath)
        }
    }
}
