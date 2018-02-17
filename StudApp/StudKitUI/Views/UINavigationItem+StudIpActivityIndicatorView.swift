//
//  UINavigationItem+StudIpActivityIndicatorView.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 30.03.16.
//  Copyright © 2016 Steffen Ryll. All rights reserved.
//

import UIKit

/// Needed for "faking" a stored property in an extension.
private var cachedRightBarButtonItemAssociationKey: UInt8 = 0

public extension UINavigationItem {
    /// Cache for right bar button item used during loading indicator visibility.
    private var cachedRightBarButtonItem: UIBarButtonItem? {
        get {
            return objc_getAssociatedObject(self, &cachedRightBarButtonItemAssociationKey) as? UIBarButtonItem
        }
        set(newValue) {
            objc_setAssociatedObject(self, &cachedRightBarButtonItemAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    /// Replaces the right bar button item with a activity indicator if enabled, restores the previous item otherwise.
    ///
    /// - Parameter hidden: Whether to hide loading indicator.
    public func setActivityIndicatorHidden(_ hidden: Bool) {
        if !hidden {
            cachedRightBarButtonItem = rightBarButtonItem
            let frame = CGRect(x: 0, y: 0, width: 32, height: 32)
            let activityIndicator = StudIpActivityIndicatorView(frame: frame)
            rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        } else {
            rightBarButtonItem = cachedRightBarButtonItem
        }
    }
}
