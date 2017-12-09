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
}
