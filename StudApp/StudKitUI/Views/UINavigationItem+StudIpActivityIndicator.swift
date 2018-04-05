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
            let activityIndicator = StudIpActivityIndicator(frame: frame)
            rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        } else {
            rightBarButtonItem = cachedRightBarButtonItem
        }
    }
}
