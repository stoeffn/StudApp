//
//  AnnouncementCell.swift
//  StudApp
//
//  Created by Steffen Ryll on 19.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit
import StudKitUI

final class AnnouncementCell: UITableViewCell {
    private let contextService = ServiceContainer.default[ContextService.self]

    // MARK: - Life Cycle

    var announcement: Announcement! {
        didSet {
            let modifiedAt = announcement.modifiedAt.formattedAsShortDifferenceFromNow
            let userFullname = announcement.user?.nameComponents.formatted()

            titleLabel.text = announcement.title
            titleLabel.numberOfLines = contextService.prefersAccessibilityContentSize ? 3 : 1
            modifiedAtLabel.text = modifiedAt
            userLabel.text = userFullname
            updateSubtitleHiddenStates()

            let modifiedBy = userFullname != nil ? "by %@".localized(userFullname ?? "") : nil
            let modifiedAtBy = ["Modified".localized, modifiedAt, modifiedBy].flatMap { $0 }.joined(separator: " ")
            accessibilityLabel = [announcement.title, modifiedAtBy].joined(separator: ", ")
        }
    }

    // MARK: - User Interface

    override var frame: CGRect {
        didSet { updateSubtitleHiddenStates() }
    }

    @IBOutlet var colorView: UIView!

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var modifiedAtLabel: UILabel!

    @IBOutlet var userContainer: UIStackView!

    @IBOutlet var userLabel: UILabel!

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        colorView.backgroundColor = color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        colorView.backgroundColor = color
    }

    @IBInspectable var color: UIColor = UI.Colors.studBlue {
        didSet {
            colorView.backgroundColor = color
        }
    }

    private func updateSubtitleHiddenStates() {
        guard let announcement = announcement else { return }
        userContainer.isHidden = announcement.user == nil
    }
}
