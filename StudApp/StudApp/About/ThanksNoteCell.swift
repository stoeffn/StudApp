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

    override init(style _: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value2, reuseIdentifier: reuseIdentifier)
        initUserInterface()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    var thanksNote: ThanksNote! {
        didSet {
            textLabel?.text = thanksNote.title
            detailTextLabel?.text = thanksNote.description

            let hasLink = thanksNote.url != nil
            selectionStyle = hasLink ? .default : .none
            textLabel?.textColor = hasLink ? tintColor : .black
        }
    }

    // MARK: - User Interface

    private func initUserInterface() {
        textLabel?.font = .preferredFont(forTextStyle: .footnote)
        textLabel?.adjustsFontForContentSizeCategory = true
        textLabel?.numberOfLines = 2

        detailTextLabel?.font = .preferredFont(forTextStyle: .footnote)
        detailTextLabel?.adjustsFontForContentSizeCategory = true
        detailTextLabel?.textColor = UI.greyTextColor
        detailTextLabel?.numberOfLines = 2
    }
}
