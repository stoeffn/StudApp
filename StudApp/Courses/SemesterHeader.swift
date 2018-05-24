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

import StudKit
import StudKitUI

final class SemesterHeader: UITableViewHeaderFooterView {
    static let estimatedHeight: CGFloat = 42

    // MARK: - Life Cycle

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initUserInterface()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    var semester: Semester! {
        didSet {
            isCollapsed = semester.state.isCollapsed
            titleLabel.text = semester.title
            titleLabel.textColor = semester.isCurrent ? UI.Colors.tint : .black
            setGlyphRotation(isCollapsed: isCollapsed, animated: true)

            accessibilityLabel = semester.title
            accessibilityValue = semester.isCurrent ? Strings.States.current.localized : nil
        }
    }

    weak var courseListViewModel: CourseListViewModel?

    // MARK: - User Interface

    let highlightAnimationDuration = 0.15
    let highlightedBackgroundColor = UIColor.lightGray.lightened(by: 0.2)

    var isHightlighted: Bool = false {
        didSet {
            backgroundView?.backgroundColor = isHightlighted ? highlightedBackgroundColor : .white
        }
    }

    var isCollapsed: Bool = false {
        didSet {
            guard isCollapsed != semester.state.isCollapsed else { return }

            semester.state.isCollapsed = isCollapsed
            courseListViewModel?.isCollapsed = isCollapsed

            setGlyphRotation(isCollapsed: isCollapsed, animated: true)
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title2).bold
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private(set) lazy var glyphImageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "DisclosureGlyph"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = UI.Colors.greyGlyph
        return view
    }()

    private func initUserInterface() {
        heightAnchor.constraint(greaterThanOrEqualToConstant: SemesterHeader.estimatedHeight).isActive = true

        addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: readableContentGuide.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: readableContentGuide.bottomAnchor).isActive = true

        addSubview(glyphImageView)
        glyphImageView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor).isActive = true
        glyphImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(_:))))

        isAccessibilityElement = true
        accessibilityTraits |= UIAccessibilityTraitButton
    }

    private func setGlyphRotation(isCollapsed: Bool, animated: Bool = true) {
        let duration = animated ? UI.defaultAnimationDuration : 0
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            self.glyphImageView.transform = CGAffineTransform(rotationAngle: isCollapsed ? 0 : .pi / 2)
        }
        animator.startAnimation()
    }

    // MARK: - User Interaction

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        UIView.animate(withDuration: highlightAnimationDuration) {
            self.isHightlighted = true
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        UIView.animate(withDuration: highlightAnimationDuration) {
            self.isHightlighted = false
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        UIView.animate(withDuration: highlightAnimationDuration) {
            self.isHightlighted = false
        }
    }

    @objc
    private func didTap(_: UITapGestureRecognizer) {
        isCollapsed = !isCollapsed
    }

    // MARK: - Accessibility

    override var accessibilityValue: String? {
        get { return isCollapsed ? Strings.States.collapsed.localized : Strings.States.expanded.localized }
        set {}
    }

    override func accessibilityActivate() -> Bool {
        isCollapsed = !isCollapsed
        return true
    }
}
