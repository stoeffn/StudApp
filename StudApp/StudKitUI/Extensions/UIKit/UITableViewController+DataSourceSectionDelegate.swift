//
//  UITableViewController+DataSourceSectionDelegate.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 23.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import StudKit

public extension DataSourceSectionDelegate where Self: UITableViewController {
    public func dataWillChange<Section: DataSourceSection>(in _: Section) {
        tableView.beginUpdates()
    }

    public func dataDidChange<Section: DataSourceSection>(in _: Section) {
        tableView.endUpdates()
    }

    public func data<Section: DataSourceSection>(changedIn _: Section.Row, at index: Int, change: DataChange<Section.Row, Int>,
                                                 in _: Section) {
        let indexPath = IndexPath(row: index, section: 0)
        switch change {
        case .insert:
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath], with: .fade)
        case let .move(newIndex):
            let newIndexPath = IndexPath(row: newIndex, section: 0)
            tableView.moveRow(at: indexPath, to: newIndexPath)
        }
    }
}
