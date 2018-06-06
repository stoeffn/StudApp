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

final class ThanksNoteCell: UITableViewCell {

    // MARK: - Life Cycle

    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        // Weirdly, you have to manually set the cell style here again. Otherwise, it defaults to the basic style.
        super.init(style: .value2, reuseIdentifier: reuseIdentifier)
        initUserInterface()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    var thanksNote: ThanksNote! {
        didSet {
            let hasLink = thanksNote.url != nil

            textLabel?.text = thanksNote.title
            detailTextLabel?.text = thanksNote.description

            selectionStyle = hasLink ? .default : .none
            textLabel?.textColor = hasLink ? UI.Colors.tint : .black

            accessoryType = hasLink ? .disclosureIndicator : .none
        }
    }

    // MARK: - User Interface

    private func initUserInterface() {
        textLabel?.font = .preferredFont(forTextStyle: .footnote)
        textLabel?.adjustsFontForContentSizeCategory = true
        textLabel?.numberOfLines = 2

        detailTextLabel?.font = .preferredFont(forTextStyle: .footnote)
        detailTextLabel?.adjustsFontForContentSizeCategory = true
        detailTextLabel?.textColor = UI.Colors.greyText
        detailTextLabel?.numberOfLines = 2
    }
}
