//
//  DataSourceDelegate.swift
//  StudKit
//
//  Created by Steffen Ryll on 19.09.17.
//  Copyright © 2017 Remonder. All rights reserved.
//

public protocol DataSourceDelegate: class {
    func dataWillChange<Source: DataSource>(in source: Source)

    func dataDidChange<Source: DataSource>(in source: Source)

    func data<Source: DataSource>(changedIn row: Source.Row, at index: IndexPath, change: DataChange<Source.Row, IndexPath>,
                                  in source: Source)

    func data<Source: DataSource>(changedIn section: Source.Section?, at index: Int, change: DataChange<Source.Section?, Int>,
                                  in source: Source)
}

// MARK: - Default Implementation

public extension DataSourceDelegate {
    func dataWillChange<Source: DataSource>(in _: Source) {}

    func dataDidChange<Source: DataSource>(in _: Source) {}

    func data<Source: DataSource>(changedIn _: Source.Row, at _: IndexPath, change _: DataChange<Source.Row, IndexPath>,
                                  in _: Source) {}

    func data<Source: DataSource>(changedIn _: Source.Section?, at _: Int, change _: DataChange<Source.Section?, Int>,
                                  in _: Source) {}
}

// MARK: - Table View Controller Implementation

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
