//
//  UISplitViewController+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 24.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension UISplitViewController {
    public var detailNavigationController: UINavigationController? {
        if isCollapsed {
            return viewControllers.first as? UINavigationController
        }
        return viewControllers.last as? UINavigationController
    }
}
