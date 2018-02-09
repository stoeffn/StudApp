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

    public static let defaultAnimationDuration = 0.3

    public enum Colors {
        public static let greyGlyph = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1)

        public static let greyText = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)

        public static let tint = UIColor(red: 0.165, green: 0.427, blue: 0.62, alpha: 1)

        public static let studBlue = UIColor(red: 0.122, green: 0.247, blue: 0.439, alpha: 1)

        public static let studRed = UIColor(red: 0.839, green: 0, blue: 0, alpha: 1)

        public static let pickerColors = [
            0: UIColor(red: 0.157, green: 0.286, blue: 0.486, alpha: 1),
            1: UIColor(red: 0.663, green: 0.714, blue: 0.796, alpha: 1),
            2: UIColor(red: 0.408, green: 0.173, blue: 0.545, alpha: 1),
            3: UIColor(red: 0.761, green: 0.667, blue: 0.816, alpha: 1),
            4: UIColor(red: 0.686, green: 0.176, blue: 0.482, alpha: 1),
            5: UIColor(red: 0.875, green: 0.671, blue: 0.792, alpha: 1),
            6: UIColor(red: 0.839, green: 0, blue: 0, alpha: 1),
            7: UIColor(red: 0.937, green: 0.6, blue: 0.6, alpha: 1),
            8: UIColor(red: 0.949, green: 0.431, blue: 0, alpha: 1),
            9: UIColor(red: 0.98, green: 0.773, blue: 0.6, alpha: 1),
            10: UIColor(red: 1, green: 0.741, blue: 0.2, alpha: 1),
            11: UIColor(red: 1, green: 0.894, blue: 0.678, alpha: 1),
            12: UIColor(red: 0.431, green: 0.678, blue: 0.0627, alpha: 1),
            13: UIColor(red: 0.773, green: 0.871, blue: 0.627, alpha: 1),
            14: UIColor(red: 0, green: 0.522, blue: 0.0706, alpha: 1),
            15: UIColor(red: 0.6, green: 0.808, blue: 0.627, alpha: 1),
            16: UIColor(red: 0.0706, green: 0.612, blue: 0.58, alpha: 1),
            17: UIColor(red: 0.627, green: 0.843, blue: 0.831, alpha: 1),
            18: UIColor(red: 0.659, green: 0.365, blue: 0.271, alpha: 1),
            19: UIColor(red: 0.863, green: 0.745, blue: 0.706, alpha: 1),
        ]

        public static let defaultPickerColor = pickerColors[0]
    }
}
