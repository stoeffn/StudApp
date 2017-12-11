//
//  UISplitViewController+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension UISplitViewController {
    public func showEmptyDetailIfApplicable() {
        guard !isCollapsed && viewControllers.count <= 1 else { return }
        performSegue(withRoute: .empty)
    }
}
