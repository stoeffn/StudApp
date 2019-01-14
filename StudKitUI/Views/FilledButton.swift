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

import UIKit

@IBDesignable
public final class FilledButton: UIButton {
    // MARK: - User Interface

    private var enabledBackgroundColor: UIColor?
    private let disabledBackgroundColor: UIColor = .lightGray

    public override var isEnabled: Bool {
        didSet {
            // Cache original background color before setting to disabled color.
            if enabledBackgroundColor == nil {
                enabledBackgroundColor = backgroundColor
            }
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                self.backgroundColor = self.isEnabled ? self.enabledBackgroundColor : self.disabledBackgroundColor
            }, completion: nil)
        }
    }

    public override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                let alpha: CGFloat = self.isHighlighted ? 0.6 : 1
                self.alpha = alpha
                self.titleLabel?.alpha = alpha
            }, completion: nil)
        }
    }

    @IBInspectable
    public var cornerRadius: CGFloat = UI.defaultCornerRadius {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}
