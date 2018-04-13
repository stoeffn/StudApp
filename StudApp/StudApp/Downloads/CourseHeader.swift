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

final class CourseHeader: UITableViewHeaderFooterView {
    static let estimatedHeight: CGFloat = 24

    // MARK: - Life Cycle

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initUserInterface()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    var course: Course? {
        didSet {
            titleLabel.text = course?.title
            updateAppearance()

            accessibilityLabel = course?.title
        }
    }

    // MARK: - User Interface

    private(set) lazy var colorView: UIView = {
        let view = UIView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isAccessibilityElement = false
        return view
    }()

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.isAccessibilityElement = false
        return label
    }()

    private func initUserInterface() {
        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

        addSubview(colorView)

        addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true

        isAccessibilityElement = true

        NotificationCenter.default.addObserver(self, selector: #selector(reduceTransparencyDidChange(notification:)),
                                               name: .UIAccessibilityReduceTransparencyStatusDidChange, object: nil)
    }

    private func updateAppearance() {
        let isTransparencyReduced = UIAccessibilityIsReduceTransparencyEnabled()
        colorView.backgroundColor = isTransparencyReduced ? course?.color : course?.color.withAlphaComponent(0.4)
    }

    // MARK: - Notifications

    @objc private func reduceTransparencyDidChange(notification _: Notification) {
        updateAppearance()
    }
}
