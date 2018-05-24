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
    func show(_ sender: Any?)

    @objc
    func color(_ sender: Any?)

    @objc
    func markAsNew(_ sender: Any?)

    @objc
    func markAsSeen(_ sender: Any?)
}

// MARK: - Utilities

func addCustomMenuItems(to menuController: UIMenuController) {
    menuController.menuItems = [
        UIMenuItem(title: Strings.Actions.share.localized, action: #selector(CustomMenuItems.share(_:))),
        UIMenuItem(title: Strings.Actions.remove.localized, action: #selector(CustomMenuItems.remove(_:))),
        UIMenuItem(title: Strings.Actions.hide.localized, action: #selector(CustomMenuItems.hide(_:))),
        UIMenuItem(title: Strings.Actions.show.localized, action: #selector(CustomMenuItems.show(_:))),
        UIMenuItem(title: Strings.Terms.color.localized, action: #selector(CustomMenuItems.color(_:))),
        UIMenuItem(title: Strings.Actions.markAsNew.localized, action: #selector(CustomMenuItems.markAsNew(_:))),
        UIMenuItem(title: Strings.Actions.markAsSeen.localized, action: #selector(CustomMenuItems.markAsSeen(_:))),
    ]
}
