//
//  UI.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreGraphics

public enum UI {
    public static let defaultCornerRadius: CGFloat = 10

    public static let defaultAnimationDuration = 0.3

    public enum Colors {
        public static let greyGlyph = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1)

        public static let greyText = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)

        public static let tint = UIColor(red: 0.165, green: 0.427, blue: 0.62, alpha: 1)

        public static let studBlue = UIColor(red: 0.122, green: 0.247, blue: 0.439, alpha: 1)

        public static let studRed = UIColor(red: 0.839, green: 0, blue: 0, alpha: 1)

        public static let pickerColors = [
            0: UIColor(red: 1, green: 0.792, blue: 0.361, alpha: 1),
            1: UIColor(red: 0.839, green: 0, blue: 0, alpha: 1),
            2: UIColor(red: 0.961, green: 0.545, blue: 0.2, alpha: 1),
            3: UIColor(red: 0.98, green: 0.773, blue: 0.6, alpha: 1),
            4: UIColor(red: 0.545, green: 0.741, blue: 0.251, alpha: 1),
            5: UIColor(red: 0.773, green: 0.871, blue: 0.624, alpha: 1),
            6: UIColor(red: 0.722, green: 0.761, blue: 0.835, alpha: 1),
            7: UIColor(red: 0.494, green: 0.573, blue: 0.69, alpha: 1),
            8: UIColor(red: 0.69, green: 0.18, blue: 0.486, alpha: 1),
        ]
    }
}
