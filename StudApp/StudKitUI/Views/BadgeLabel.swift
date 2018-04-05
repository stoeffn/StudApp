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

/// A `UILabel` made to look like a badge or tag by setting the corner radius and insets automatically.
@IBDesignable
class BadgeLabel: UILabel {

    // MARK: - Life Cycle

    public required init?(coder aDecoder: NSCoder) {
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

    open override var intrinsicContentSize: CGSize {
        sizeToFit()
        return CGSize(width: frame.width + insets.left + insets.right,
                      height: insets.top + font.pointSize + insets.bottom)
    }
}
