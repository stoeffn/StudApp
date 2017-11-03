//
//  DataSourceDelegate+UITableViewController.swift
//  RemonderKit
//
//  Created by Steffen Ryll on 19.09.17.
//  Copyright © 2017 Remonder. All rights reserved.
//

public extension DataSourceDelegate where Self : UITableViewController {
    func dataWillChange<Source>(in dataSource: Source) {
        tableView.beginUpdates()
    }

    func dataDidChange<Source>(in dataSource: Source) {
        tableView.endUpdates()
    }

    func data<Source: DataSource>(changedIn: Source.Row, at indexPath: IndexPath,
                                  change: DataChange<Source.Row, IndexPath>, in dataSource: Source) {
        switch change {
        case .insert:
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .update(_):
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move(let newIndexPath):
            tableView.moveRow(at: indexPath, to: newIndexPath)
        }
    }

    func data<Source: DataSource>(changedIn section: Source.Section, at index: Int,
                                  change: DataChange<Source.Section, Int>, in dataSource: Source) {
        let indexSet = IndexSet(integer: index)
        switch change {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .fade)
        case .update(_):
            tableView.reloadSections(indexSet, with: .automatic)
        case .move(let newIndex):
            tableView.moveSection(index, toSection: newIndex)
        }
    }
}
