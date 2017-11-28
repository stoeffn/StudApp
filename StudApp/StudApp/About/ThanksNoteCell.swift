//
//  ThanksNoteCell.swift
//  StudApp
//
//  Created by Steffen Ryll on 28.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class ThanksNoteCell: UITableViewCell {
    // MARK: - Life Cycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value2, reuseIdentifier: reuseIdentifier)
        initUserInterface()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    var thanks: ThanksNote! {
        didSet {
            textLabel?.text = thanks.title
            detailTextLabel?.text = thanks.description
        }
    }

    // MARK: - User Interface

    private func initUserInterface() {
        textLabel?.font = .preferredFont(forTextStyle: .footnote)
        textLabel?.adjustsFontForContentSizeCategory = true

        detailTextLabel?.font = .preferredFont(forTextStyle: .footnote)
        detailTextLabel?.adjustsFontForContentSizeCategory = true
        detailTextLabel?.textColor = UI.greyTextColor
    }
}
