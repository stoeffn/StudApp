//
//  CourseHeader.swift
//  StudApp
//
//  Created by Steffen Ryll on 22.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class CourseHeader: UITableViewHeaderFooterView {
    static let height: CGFloat = 24

    // MARK: - Life Cycle

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initUserInterface()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    var course: Course! {
        didSet {
            colorView.backgroundColor = course.state.color.withAlphaComponent(0.2)
            titleLabel.text = course.title
        }
    }

    // MARK: - User Interface

    private(set) lazy var colorView: UIView = {
        let view = UIView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private func initUserInterface() {
        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

        addSubview(colorView)

        addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: readableContentGuide.centerYAnchor).isActive = true
    }
}
