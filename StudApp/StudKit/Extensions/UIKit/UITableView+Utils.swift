//
//  UITableView+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 09.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
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
        return indexPathsForVisibleRows?
            .map { (indexPath: $0, rect: rectForRow(at: $0)) }
            .filter { $0.rect.origin.y + $0.rect.size.height - contentOffset.y - contentInset.top > 0 }
            .first?
            .indexPath
    }
}
