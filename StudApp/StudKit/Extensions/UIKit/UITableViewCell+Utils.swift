//
//  UITableViewCell+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 07.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension UITableViewCell {
    /// Sets the cell's accessory type to either `.none` or `.disclosureIndicator`, depending on whether the optional
    /// split view controller given is collapsed. Defaults to `.none`.
    func setDisclosureIndicatorHidden(for splitViewController: UISplitViewController?) {
        accessoryType = splitViewController?.isCollapsed ?? true ? .disclosureIndicator : .none
    }
}
