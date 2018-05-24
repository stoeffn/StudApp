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

import CoreGraphics
import StudKit

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
            0: (color: UIColor(red: 1, green: 0.792, blue: 0.361, alpha: 1), title: Strings.Colors.yellow.localized),
            1: (color: UIColor(red: 0.839, green: 0, blue: 0, alpha: 1), title: Strings.Colors.red.localized),
            2: (color: UIColor(red: 0.961, green: 0.545, blue: 0.2, alpha: 1), title: Strings.Colors.orange.localized),
            3: (color: UIColor(red: 0.98, green: 0.773, blue: 0.6, alpha: 1), title: Strings.Colors.lightOrange.localized),
            4: (color: UIColor(red: 0.545, green: 0.741, blue: 0.251, alpha: 1), title: Strings.Colors.green.localized),
            5: (color: UIColor(red: 0.773, green: 0.871, blue: 0.624, alpha: 1), title: Strings.Colors.lightGreen.localized),
            6: (color: UIColor(red: 0.722, green: 0.761, blue: 0.835, alpha: 1), title: Strings.Colors.lightBlue.localized),
            7: (color: UIColor(red: 0.494, green: 0.573, blue: 0.69, alpha: 1), title: Strings.Colors.blue.localized),
            8: (color: UIColor(red: 0.69, green: 0.18, blue: 0.486, alpha: 1), title: Strings.Colors.purple.localized),
        ]
    }
}
