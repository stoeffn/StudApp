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

@objc
public protocol CustomMenuItems: NSObjectProtocol {
    @objc
    func share(_ sender: Any?)

    @objc
    func remove(_ sender: Any?)

    @objc
    func hide(_ sender: Any?)

    @objc
    func color(_ sender: Any?)
}

// MARK: - Utilities

func addCustomMenuItems(to menuController: UIMenuController) {
    menuController.menuItems = [
        UIMenuItem(title: "Share".localized, action: #selector(CustomMenuItems.share(_:))),
        UIMenuItem(title: "Remove".localized, action: #selector(CustomMenuItems.remove(_:))),
        UIMenuItem(title: "Hide".localized, action: #selector(CustomMenuItems.hide(_:))),
        UIMenuItem(title: "Color".localized, action: #selector(CustomMenuItems.color(_:))),
    ]
}
