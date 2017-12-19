//
//  AnnouncementCell.swift
//  StudApp
//
//  Created by Steffen Ryll on 19.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class AnnouncementCell: UITableViewCell {
    var announcement: Announcement! {
        didSet {
            titleLabel.text = announcement.title
            createdAtLabel.text = announcement.createdAt.formattedAsShortDifferenceFromNow
        }
    }

    // MARK: - User Interface

    @IBOutlet weak var colorView: UIView!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var createdAtGlyph: UIImageView!

    @IBOutlet weak var createdAtLabel: UILabel!

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
}
