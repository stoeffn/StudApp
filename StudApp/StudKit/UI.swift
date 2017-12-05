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
            UI.Colors.studBlue,
            UI.Colors.studRed
        ]
    }
}
