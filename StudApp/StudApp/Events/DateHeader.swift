//
//  DateHeader.swift
//  StudApp
//
//  Created by Steffen Ryll on 27.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class DateHeader: UITableViewHeaderFooterView {
    static let height: CGFloat = 48

    // MARK: - Life Cycle

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initUserInterface()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    var date: Date! {
        didSet {
            titleLabel.text = date.formattedAsRelativeDateFromNow
        }
    }

    // MARK: - User Interface

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title2).bold
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private func initUserInterface() {
        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

        addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: readableContentGuide.bottomAnchor, constant: 6).isActive = true
    }
}
