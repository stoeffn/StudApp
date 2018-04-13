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

public extension UITableView {
    public func update(updates: @escaping () -> Void) {
        if #available(iOSApplicationExtension 11.0, *) {
            performBatchUpdates(updates, completion: nil)
        } else {
            beginUpdates()
            updates()
            endUpdates()
        }
    }

    public var topMostIndexPath: IndexPath? {
        let sectionHeaderHeight = delegate?.tableView?(self, heightForHeaderInSection: 0) ?? 0
        let indexPathsAndRects = indexPathsForVisibleRows?.map { (indexPath: $0, rect: rectForRow(at: $0)) }
        return indexPathsAndRects?
            .filter { $0.rect.origin.y - contentOffset.y + contentInset.top - sectionHeaderHeight > 0 }
            .first?
            .indexPath
    }
}
