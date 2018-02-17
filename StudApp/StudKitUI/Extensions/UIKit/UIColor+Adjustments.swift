//
//  UIColor+Adjustments.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 07.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension UIColor {
    public func lightened(by percentage: CGFloat = 0.25) -> UIColor {
        return brightnessAdjusted(by: abs(percentage))
    }

    public func darkened(by percentage: CGFloat = 0.25) -> UIColor {
        return brightnessAdjusted(by: -1 * abs(percentage))
    }

    public func brightnessAdjusted(by percentage: CGFloat = 0.25) -> UIColor {
        let components = self.components
        return UIColor(red: max(min(components.red + percentage, 1.0), 0),
                       green: max(min(components.green + percentage, 1.0), 0),
                       blue: max(min(components.blue + percentage, 1.0), 0),
                       alpha: components.alpha)
    }
}
