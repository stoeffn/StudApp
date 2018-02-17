//
//  SemesterHeader.swift
//  StudApp
//
//  Created by Steffen Ryll on 05.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit
import StudKitUI

final class SemesterHeader: UITableViewHeaderFooterView {
    static let height: CGFloat = 42

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
            titleLabel.textColor = semester.isCurrent ? UI.Colors.studBlue : .black
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
            setGlyphRotation(isCollapsed: isCollapsed, animated: true)
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
        addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: readableContentGuide.centerYAnchor).isActive = true

        addSubview(glyphImageView)
        glyphImageView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor).isActive = true
        glyphImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(_:))))
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
        semester.state.isCollapsed = !semester.state.isCollapsed
        courseListViewModel?.isCollapsed = semester.state.isCollapsed
        isCollapsed = semester.state.isCollapsed
    }
}
