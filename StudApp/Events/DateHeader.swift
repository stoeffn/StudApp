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

final class DateHeader: UITableViewHeaderFooterView {
    static let estimatedHeight: CGFloat = 64

    // MARK: - Life Cycle

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initUserInterface()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    deinit {
        updateTimer.invalidate()
    }

    var date: Date! {
        didSet { updateLabel() }
    }

    private lazy var updateTimer = Timer(fire: Date().startOfDay, interval: 60 * 60 * 24, repeats: true) { [weak self] _ in
        self?.updateLabel()
    }

    // MARK: - User Interface

    private(set) lazy var spacingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private(set) lazy var whiteView: UIView = {
        let view = UIView()
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        view.backgroundColor = .white
        return view
    }()

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title1).bold
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private func initUserInterface() {
        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

        addSubview(whiteView)

        addSubview(spacingView)
        spacingView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor).isActive = true
        spacingView.topAnchor.constraint(equalTo: readableContentGuide.topAnchor).isActive = true
        spacingView.bottomAnchor.constraint(equalTo: readableContentGuide.bottomAnchor).isActive = true
        spacingView.widthAnchor.constraint(greaterThanOrEqualToConstant: 72).isActive = true
        spacingView.widthAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true

        let widthConstraint = spacingView.widthAnchor.constraint(equalTo: readableContentGuide.widthAnchor, multiplier: 0.2)
        widthConstraint.priority = .defaultHigh
        widthConstraint.isActive = true

        addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: spacingView.trailingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: readableContentGuide.bottomAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: spacingView.heightAnchor, multiplier: 0.8).isActive = true

        updateAppearance()

        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraits.button

        NotificationCenter.default.addObserver(self, selector: #selector(reduceTransparencyDidChange(notification:)),
                                               name: UIAccessibility.reduceTransparencyStatusDidChangeNotification, object: nil)

        RunLoop.main.add(updateTimer, forMode: .defaultRunLoopMode)
    }

    private func updateAppearance() {
        let isTransparencyReduced = UIAccessibility.isReduceTransparencyEnabled
        whiteView.isHidden = !isTransparencyReduced
    }

    private func updateLabel() {
        let formattedDate = date.formattedAsRelativeDateFromNow
        titleLabel.text = formattedDate
        accessibilityLabel = formattedDate
    }

    // MARK: - Notifications

    @objc
    private func reduceTransparencyDidChange(notification _: Notification) {
        updateAppearance()
    }
}
