//
//  DataSourceDelegate+UITableView.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 17.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import StudKit

public extension DataSourceDelegate where Self: UITableViewController {
    func dataWillChange<Source>(in _: Source) {
        tableView.beginUpdates()
    }

    func dataDidChange<Source>(in _: Source) {
        tableView.endUpdates()
    }

    func data<Source: DataSource>(changedIn _: Source.Row, at indexPath: IndexPath, change: DataChange<Source.Row, IndexPath>,
                                  in _: Source) {
        switch change {
        case .insert:
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath], with: .fade)
        case let .move(newIndexPath):
            tableView.moveRow(at: indexPath, to: newIndexPath)
        }
    }

    func data<Source: DataSource>(changedIn _: Source.Section?, at index: Int, change: DataChange<Source.Section?, Int>,
                                  in _: Source) {
        let indexSet = IndexSet(integer: index)
        switch change {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        case .update:
            tableView.reloadSections(indexSet, with: .fade)
        case let .move(newIndex):
            tableView.moveSection(index, toSection: newIndex)
        }
    }
}
