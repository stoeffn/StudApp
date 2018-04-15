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
