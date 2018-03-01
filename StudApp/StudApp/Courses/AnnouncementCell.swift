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
    var announcement: Announcement! {
        didSet {
            titleLabel.text = announcement.title
            modifiedAtLabel.text = announcement.modifiedAt.formattedAsShortDifferenceFromNow
            userLabel.text = announcement.user?.nameComponents.formatted()
            updateSubtitleHiddenStates()
        }
    }

    // MARK: - User Interface

    override var frame: CGRect {
        didSet { updateSubtitleHiddenStates() }
    }

    @IBOutlet var colorView: UIView!

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var modifiedAtLabel: UILabel!

    @IBOutlet weak var userContainer: UIStackView!

    @IBOutlet weak var userLabel: UILabel!

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
