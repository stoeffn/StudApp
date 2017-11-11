//
//  DataSourceSectionDelegate+UITableViewController.swift
//  RemonderKit
//
//  Created by Steffen Ryll on 19.09.17.
//  Copyright © 2017 Remonder. All rights reserved.
//

public extension DataSourceSectionDelegate where Self: UITableViewController {
    func dataWillChange<Section: DataSourceSection>(in _: Section) {
        tableView.beginUpdates()
    }

    func dataDidChange<Section: DataSourceSection>(in _: Section) {
        tableView.endUpdates()
    }

    func data<Section: DataSourceSection>(changedIn _: Section.Row, at index: Int,
                                          change: DataChange<Section.Row, Int>, in _: Section) {
        let indexPath = IndexPath(row: index, section: 0)
        switch change {
        case .insert:
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case let .move(newIndex):
            let newIndexPath = IndexPath(row: newIndex, section: 0)
            tableView.moveRow(at: indexPath, to: newIndexPath)
        }
    }
}
