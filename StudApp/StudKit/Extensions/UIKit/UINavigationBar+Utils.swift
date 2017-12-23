//
//  UINavigationBar+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension UINavigationBar {
    /// Remove or restores this bar's background color, effect, and the bottom hairline.
    public func setBackgroundHidden(_ hidden: Bool) {
        if hidden {
            //barTintColor = .clear
            setBackgroundImage(UIImage(), for: .default)
            shadowImage = UIImage()
        } else {
            setBackgroundImage(nil, for: .default)
            shadowImage = nil
        }
    }
}
