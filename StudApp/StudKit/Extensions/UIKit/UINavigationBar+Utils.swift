//
//  UINavigationBar+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension UINavigationBar {
    /// Remove this bar's background color and effect as well as the bottom hairline.
    public func removeBackground() {
        barTintColor = .clear
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
    }
}
