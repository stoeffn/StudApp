//
//  GroupedTextField.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
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
                if #available(iOSApplicationExtension 11.0, *) {
                    layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                }
            case .middle?:
                if #available(iOSApplicationExtension 11.0, *) {
                    layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                }
            case .bottom?:
                if #available(iOSApplicationExtension 11.0, *) {
                    layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                }
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
