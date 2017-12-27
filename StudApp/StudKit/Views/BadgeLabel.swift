//
//  BadgeLabel.swift
//  StudKit
//
//  Created by Steffen Ryll on 27.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// A `UILabel` made to look like a badge or tag by setting the corner radius and insets automatically.
@IBDesignable
class BadgeLabel: UILabel {
    // MARK: - Life Cycle

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUserInterface()
    }

    /// Creates a badge with a certain title an an optional font.
    public init(title: String, font: UIFont = .preferredFont(forTextStyle: .footnote)) {
        super.init(frame: CGRect.zero)
        self.font = font
        text = title
        initUserInterface()
    }

    // MARK: - User Interface

    private func initUserInterface() {
        frame.size = intrinsicContentSize
        layer.masksToBounds = true
        layer.cornerRadius = 2
    }

    var insets: UIEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4) {
        didSet { initUserInterface() }
    }

    // MARK: - Layout

    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }

    override open var intrinsicContentSize: CGSize {
        sizeToFit()
        return CGSize(width: frame.size.width + insets.left + insets.right,
                      height: insets.top + font.pointSize + insets.bottom)
    }
}

