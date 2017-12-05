//
//  UI.swift
//  StudApp
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreGraphics

public enum UI {
    public static let defaultCornerRadius: CGFloat = 10

    public enum Colors {
        public static let greyText = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)

        public static let tint = UIColor(red: 0.165, green: 0.427, blue: 0.62, alpha: 1)

        public static let studBlue = UIColor(red: 0.165, green: 0.29, blue: 0.486, alpha: 1)

        public static let studRed = UIColor(red: 0.827, green: 0.0667, blue: 0.125, alpha: 1)

        public static let pickerColors = [
            0: UIColor(red: 1, green: 0.8, blue: 0, alpha: 1),
            1: UIColor(red: 1, green: 0.584, blue: 0, alpha: 1),
            2: UIColor(red: 0.98, green: 0.4, blue: 0.118, alpha: 1),
            3: UIColor(red: 1, green: 0.231, blue: 0.188, alpha: 1),
            4: UIColor(red: 0.929, green: 0.306, blue: 0.71, alpha: 1),
            5: UIColor(red: 0.114, green: 0.0706, blue: 0.443, alpha: 1),
            6: UIColor(red: 0.125, green: 0.259, blue: 0.651, alpha: 1),
            7: UIColor(red: 0.118, green: 0.388, blue: 0.933, alpha: 1),
            8: UIColor(red: 0, green: 0.847, blue: 0.922, alpha: 1),
            9: UIColor(red: 0.345, green: 0.918, blue: 0.631, alpha: 1),
            10: UIColor(red: 0.00784, green: 0.698, blue: 0.122, alpha: 1)
        ]
    }
}
