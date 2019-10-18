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
public final class GroupedTextField: UITextField {
    // MARK: - Life Cycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initUserInterface()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    // MARK: - User Interface

    private func initUserInterface() {
        borderStyle = .none
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBInspectable
    public var cornerRadius: CGFloat = UI.defaultCornerRadius {
        didSet {
            layer.cornerRadius = cornerRadius
            layoutSubviews()
        }
    }

    @IBInspectable
    public var position: String = Position.middle.rawValue {
        didSet {
            switch Position(rawValue: position) {
            case .top?:
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            case .middle?:
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            case .bottom?:
                layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            case .none:
                fatalError("Cannot set position with raw value '\(position)'.")
            }
        }
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: cornerRadius, dy: cornerRadius / 2)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    // MARK: - Position

    public enum Position: String {
        case top, middle, bottom
    }
}
