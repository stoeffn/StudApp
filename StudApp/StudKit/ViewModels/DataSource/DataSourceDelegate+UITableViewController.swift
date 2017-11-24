//
//  DataSourceDelegate+UITableViewController.swift
//  StudKit
//
//  Created by Steffen Ryll on 19.09.17.
//  Copyright © 2017 Remonder. All rights reserved.
//

public extension DataSourceDelegate where Self: UITableViewController {
    func dataWillChange<Source>(in _: Source) {
        tableView.beginUpdates()
    }

    func dataDidChange<Source>(in _: Source) {
        tableView.endUpdates()
    }

    func data<Source: DataSource>(changedIn _: Source.Row, at indexPath: IndexPath,
                                  change: DataChange<Source.Row, IndexPath>, in _: Source) {
        switch change {
        case .insert:
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case let .move(newIndexPath):
            tableView.moveRow(at: indexPath, to: newIndexPath)
        }
    }

    func data<Source: DataSource>(changedIn _: Source.Section, at index: Int,
                                  change: DataChange<Source.Section, Int>, in _: Source) {
        let indexSet = IndexSet(integer: index)
        switch change {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .fade)
        case .update:
            tableView.reloadSections(indexSet, with: .automatic)
        case let .move(newIndex):
            tableView.moveSection(index, toSection: newIndex)
        }
    }
}
