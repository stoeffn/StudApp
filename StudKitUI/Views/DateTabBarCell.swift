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
        selectedBackgroundViewCircle.layer.cornerRadius = selectedBackgroundViewCircle.bounds.width / 2
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
        initSelectedBackground()
        initLabels()

        updateAppearance(animated: false)
    }

    private func initLabels() {
        addSubview(weekdayLabel)
        weekdayLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        weekdayLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true

        addSubview(dateLabel)
        dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 8).isActive = true
    }

    private func initSelectedBackground() {
        addSubview(selectedBackgroundViewCircle)
        selectedBackgroundViewCircle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        selectedBackgroundViewCircle.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 8).isActive = true
        selectedBackgroundViewCircle.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7).isActive = true
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
        didSet { updateAppearance(animated: false) }
    }

    var date: Date? {
        didSet {
            weekdayLabel.text = date?.formatted(using: .shortWeekday)
            dateLabel.text = String(date?.component(.day) ?? 0)
            updateAppearance(animated: false)
        }
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
        isUserInteractionEnabled = isEnabled
        tintColor = UI.Colors.tint

        let duration = animated ? UI.defaultAnimationDuration : 0
        let textColor: UIColor = isEnabled ? .label : .lightGray
        let highlightsCell = isEnabled && (isHighlighted || isSelected)

        // Set the color here because the `tintColor` is not set correctly during initialization.
        selectedBackgroundViewCircle.backgroundColor = tintColor

        UIView.transition(with: weekdayLabel, duration: duration, options: .transitionCrossDissolve, animations: {
            self.weekdayLabel.textColor = highlightsCell ? self.tintColor : textColor
        }, completion: nil)

        UIView.transition(with: dateLabel, duration: duration, options: .transitionCrossDissolve, animations: {
            self.dateLabel.textColor = highlightsCell ? UIColor.white : textColor
        }, completion: nil)

        let animations = {
            self.selectedBackgroundViewCircle.alpha = highlightsCell ? 1 : 0
            self.selectedBackgroundViewCircle.transform = self.selectedBackgroundCircleTransform
        }
        UIView.animate(withDuration: duration * 1.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0,
                       options: [], animations: animations, completion: nil)
    }
}
