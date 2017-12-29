//
//  DateTabBarCell.swift
//  StudKit
//
//  Created by Steffen Ryll on 29.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

final class DateTabBarCell: UICollectionViewCell {
    // MARK: - Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUserInterface()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        selectedBackgroundViewCircle.layer.cornerRadius = selectedBackgroundViewCircle.bounds.size.width / 2
    }

    // MARK: - User Interface

    private static let hiddenSelectedBackgroundViewTransform = CGAffineTransform(scaleX: 0.25, y: 0.25)

    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = .preferredFont(forTextStyle: .caption2)
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()

    private let selectedBackgroundViewCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.transform = hiddenSelectedBackgroundViewTransform
        return view
    }()

    private func initUserInterface() {
        widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.75).isActive = true

        initSelectedBackground()
        initLabels()

        updateAppearance(animated: false)
    }

    private func initLabels() {
        addSubview(weekdayLabel)
        weekdayLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        weekdayLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -18).isActive = true

        addSubview(dateLabel)
        dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10).isActive = true
    }

    private func initSelectedBackground() {
        addSubview(selectedBackgroundViewCircle)
        selectedBackgroundViewCircle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        selectedBackgroundViewCircle.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10).isActive = true
        selectedBackgroundViewCircle.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        selectedBackgroundViewCircle.widthAnchor.constraint(equalTo: selectedBackgroundViewCircle.heightAnchor).isActive = true
    }

    // MARK: - User Interaction

    override var isHighlighted: Bool {
        didSet { updateAppearance() }
    }

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    var isEnabled: Bool = true {
        didSet { updateAppearance() }
    }

    var date: Date? {
        didSet { updateAppearance() }
    }

    private var selectedBackgroundCircleTransform: CGAffineTransform {
        switch (isEnabled, isHighlighted, isSelected) {
        case (true, true, true), (true, true, false):
            return CGAffineTransform(scaleX: 1.25, y: 1.25)
        case (true, false, true):
            return .identity
        default:
            return DateTabBarCell.hiddenSelectedBackgroundViewTransform
        }
    }

    private func updateAppearance(animated: Bool = true) {
        weekdayLabel.text = date?.formatted(using: .shortWeekday)
        dateLabel.text = String(date?.component(.day) ?? 0)

        let duration = animated ? UI.defaultAnimationDuration : 0
        let textColor: UIColor = isEnabled ? .black : .lightGray

        // Set the color here because the `tintColor` is not set correctly during initialization.
        selectedBackgroundViewCircle.backgroundColor = tintColor

        UIView.transition(with: weekdayLabel, duration: duration, options: .transitionCrossDissolve, animations: {
            self.weekdayLabel.textColor = self.isHighlighted || self.isSelected ? self.tintColor : textColor
        }, completion: nil)
        UIView.transition(with: dateLabel, duration: duration, options: .transitionCrossDissolve, animations: {
            self.dateLabel.textColor = self.isHighlighted || self.isSelected ? UIColor.white : textColor
        }, completion: nil)
        UIView.animate(withDuration: duration * 1.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0,
                       options: [], animations: {
            self.selectedBackgroundViewCircle.alpha = self.isHighlighted || self.isSelected ? 1 : 0
            self.selectedBackgroundViewCircle.transform = self.selectedBackgroundCircleTransform
        }, completion: nil)
    }
}
