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
            tableView.insertRows(at: [indexPath], with: .top)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .top)
        case .update:
            tableView.reloadRows(at: [indexPath], with: .fade)
        case let .move(newIndex):
            let newIndexPath = IndexPath(row: newIndex, section: 0)
            tableView.moveRow(at: indexPath, to: newIndexPath)
        }
    }
}
