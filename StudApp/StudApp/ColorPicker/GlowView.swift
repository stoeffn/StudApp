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
            highlightColor = color?.lightened(by: 0.1)
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
