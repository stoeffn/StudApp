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

public extension UIColor {
    func lightened(by percentage: CGFloat = 0.25) -> UIColor {
        return brightnessAdjusted(by: abs(percentage))
    }

    func darkened(by percentage: CGFloat = 0.25) -> UIColor {
        return brightnessAdjusted(by: -1 * abs(percentage))
    }

    func brightnessAdjusted(by percentage: CGFloat = 0.25) -> UIColor {
        let components = self.components
        return UIColor(red: max(min(components.red + percentage, 1.0), 0),
                       green: max(min(components.green + percentage, 1.0), 0),
                       blue: max(min(components.blue + percentage, 1.0), 0),
                       alpha: components.alpha)
    }
}
