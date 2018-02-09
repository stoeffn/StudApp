//
//  FilledButton.swift
//  StudApp
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
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
