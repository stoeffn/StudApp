//
//  GlowView.swift
//  StudSync
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKitUI

@IBDesignable
final class GlowView: UIView {

    // MARK: - Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUserInterface()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    // MARK: - User Interface

    private var highlightColor: UIColor?

    private func initUserInterface() {
        clipsToBounds = false

        color = color ?? backgroundColor

        layer.cornerRadius = 4
        layer.shadowOffset = CGSize(width: 2, height: 2)
    }

    @IBInspectable var color: UIColor? {
        didSet {
            highlightColor = color?.lightened(by: 0.15)
            layer.shadowColor = highlightColor?.cgColor
            backgroundColor = isHighlighted ? highlightColor : color
        }
    }

    @IBInspectable var isHighlighted: Bool = false {
        didSet {
            guard isHighlighted != oldValue else { return }
            let animator = UIViewPropertyAnimator(duration: 0.15, curve: .easeInOut) {
                self.backgroundColor = self.isHighlighted ? self.highlightColor : self.color
                self.layer.shadowRadius = self.isHighlighted ? 16 : 0
                self.layer.shadowOpacity = self.isHighlighted ? 0.75 : 0
            }
            animator.startAnimation()
        }
    }
}
