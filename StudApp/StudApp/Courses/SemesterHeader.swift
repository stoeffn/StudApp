//
//  SemesterHeader.swift
//  StudApp
//
//  Created by Steffen Ryll on 05.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

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

    var semester: Semester? {
        didSet {
            guard let semester = semester else { return }
            titleLabel.text = semester.title
            titleLabel.textColor = semester.isCurrent ? UI.Colors.studBlue : .black
        }
    }

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
            guard isCollapsed != oldValue else { return }
            setGlyphRotation(isCollapsed: isCollapsed, animated: true)
        }
    }

    lazy private(set) var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title2).bold
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    lazy private(set) var glyphImageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "Image"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .lightGray
        return view
    }()

    private func initUserInterface() {
        backgroundView?.backgroundColor = .white

        addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: readableContentGuide.centerYAnchor).isActive = true

        addSubview(glyphImageView)
        glyphImageView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor).isActive = true
        glyphImageView.topAnchor.constraint(equalTo: readableContentGuide.topAnchor).isActive = true
        glyphImageView.bottomAnchor.constraint(equalTo: readableContentGuide.bottomAnchor).isActive = true
        glyphImageView.widthAnchor.constraint(equalTo: glyphImageView.heightAnchor).isActive = true

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(_:))))
    }

    private func setGlyphRotation(isCollapsed: Bool, animated: Bool = true) {
        let duration = animated ? 0.3 : 0
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            self.glyphImageView.transform = CGAffineTransform(rotationAngle: isCollapsed ? .pi : -.pi / 2)
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
    private func didTap(_ sender: UITapGestureRecognizer) {
        // TODO
    }
}
