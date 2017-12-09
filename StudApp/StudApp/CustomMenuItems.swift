//
//  CustomMenuItems.swift
//  StudApp
//
//  Created by Steffen Ryll on 09.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit

@objc
public protocol CustomMenuItems: NSObjectProtocol {
    @objc func share(_ sender: Any?)
}

// MARK: - Utilities

func addCustomMenuItems(to menuController: UIMenuController) {
    menuController.menuItems = [
        UIMenuItem(title: "Share".localized, action: #selector(CustomMenuItems.share(_:)))
    ]
}
