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

final class SemesterCell: UITableViewCell {

    // MARK: - Life Cycle

    var semester: Semester! {
        didSet {
            let beginsAt = semester.beginsAt.formatted(using: .monthAndYear)
            let endsAt = semester.endsAt.formatted(using: .monthAndYear)

            titleLabel.text = semester.title
            monthRangeLabel.text = "%@ – %@".localized(beginsAt, endsAt)
            isHiddenSwitch.isOn = !semester.state.isHidden

            accessibilityLabel = [semester.title, "from %@ to %@".localized(beginsAt, endsAt)].joined(separator: ", ")
        }
    }

    // MARK: - User Interface

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var monthRangeLabel: UILabel!

    @IBOutlet var isHiddenSwitch: UISwitch!

    // MARK: - User Interaction

    @IBAction
    func isHiddenSwitchValueChanged(_: Any) {
        semester?.state.isHidden = !isHiddenSwitch.isOn
    }

    // MARK: - Accessibility

    override var accessibilityValue: String? {
        get { return isHiddenSwitch.isOn ? "Visible".localized : "Hidden".localized }
        set {}
    }

    override func accessibilityActivate() -> Bool {
        isHiddenSwitch.setOn(!isHiddenSwitch.isOn, animated: true)
        semester?.state.isHidden = !isHiddenSwitch.isOn
        return true
    }
}
