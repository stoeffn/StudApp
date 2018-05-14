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
public final class StudIpActivityIndicator: UIView {

    // MARK: - Life Cycle

    convenience init() {
        self.init(frame: .zero)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyles()
        applyAnimations()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applyStyles()
        applyAnimations()
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        applyStyles()
    }

    // MARK: - Layers

    private lazy var outerCircle: CAShapeLayer = {
        let circle = CAShapeLayer()
        circle.lineCap = kCALineCapButt
        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = UI.Colors.studBlue.cgColor
        circle.strokeStart = 0
        circle.strokeEnd = 0.75
        return circle
    }()

    private lazy var innerCircle: CAShapeLayer = {
        let circle = CAShapeLayer()
        circle.fillColor = UI.Colors.studRed.cgColor
        circle.strokeColor = UIColor.clear.cgColor
        return circle
    }()

    // MARK: - Animations

    private lazy var rotateAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 1
        animation.repeatCount = .infinity
        animation.fromValue = CGFloat.pi / 2
        animation.toValue = CGFloat.pi / 2 * 5
        animation.isRemovedOnCompletion = false
        return animation
    }()

    private lazy var strokeAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1
        animation.repeatCount = .infinity
        animation.fromValue = 0.75
        animation.toValue = 0.25
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.isRemovedOnCompletion = false
        return animation
    }()

    // MARK: - User Interface

    public override var frame: CGRect {
        didSet { applyStyles() }
    }

    func applyStyles() {
        backgroundColor = .clear

        outerCircle.frame = bounds
        outerCircle.path = UIBezierPath(ovalIn: bounds).cgPath
        outerCircle.lineWidth = bounds.width / 5.7
        layer.addSublayer(outerCircle)

        innerCircle.path = UIBezierPath(ovalIn: bounds.insetBy(dx: bounds.width / 3.5, dy: bounds.width / 3.5)).cgPath
        layer.addSublayer(innerCircle)

        guard #available(iOSApplicationExtension 11.0, *) else { return }
        accessibilityIgnoresInvertColors = true
    }

    private func applyAnimations() {
        outerCircle.add(rotateAnimation, forKey: "rotation")
        outerCircle.add(strokeAnimation, forKey: "stroke")
    }
}
