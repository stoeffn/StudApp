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
import StudKitUI

final class AnnouncementCell: UITableViewCell {

    // MARK: - Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        guard #available(iOS 11, *) else { return }
        unreadIndicatorView.accessibilityIgnoresInvertColors = true
        colorView.accessibilityIgnoresInvertColors = true
    }

    var announcement: Announcement! {
        didSet {
            let modifiedAt = announcement.modifiedAt.formattedAsShortDifferenceFromNow
            let userFullname = announcement.user?.nameComponents.formatted()

            unreadIndicatorContainerView.isHidden = !announcement.isNew

            titleLabel.text = announcement.title
            titleLabel.numberOfLines = Targets.current.prefersAccessibilityContentSize ? 3 : 1

            modifiedAtLabel.text = modifiedAt
            userLabel.text = userFullname
            updateSubtitleHiddenStates()

            let modifiedBy = userFullname != nil ? "by %@".localized(userFullname ?? "") : nil
            let modifiedAtBy = ["Modified".localized, modifiedAt, modifiedBy].compactMap { $0 }.joined(separator: " ")
            accessibilityLabel = [announcement.title, modifiedAtBy].joined(separator: ", ")
        }
    }

    // MARK: - User Interface

    override var frame: CGRect {
        didSet { updateSubtitleHiddenStates() }
    }

    @IBOutlet var colorView: UIView!

    @IBOutlet var unreadIndicatorContainerView: UIView!

    @IBOutlet var unreadIndicatorView: UIView!

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var modifiedAtLabel: UILabel!

    @IBOutlet var userContainer: UIStackView!

    @IBOutlet var userLabel: UILabel!

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        unreadIndicatorView.backgroundColor = color
        colorView.backgroundColor = color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        unreadIndicatorView.backgroundColor = color
        colorView.backgroundColor = color
    }

    @IBInspectable var color: UIColor = UI.Colors.studBlue {
        didSet {
            unreadIndicatorView.backgroundColor = color
            colorView.backgroundColor = color
        }
    }

    private func updateSubtitleHiddenStates() {
        guard let announcement = announcement else { return }
        userContainer.isHidden = announcement.user == nil
    }
}
