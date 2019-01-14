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

public final class ActionCell: UITableViewCell {
    // MARK: - Life Cycle

    public override func awakeFromNib() {
        super.awakeFromNib()

        actionButton.addTarget(self, action: #selector(actionButtonTapped(sender:)), for: .touchUpInside)
    }

    // MARK: - User Interface

    @IBOutlet public var titleLabel: UILabel!

    @IBOutlet public var subtitleLabel: UILabel!

    @IBOutlet public var actionButton: UIButton!

    // MARK: - User Interaction

    public var action: (() -> Void)?

    @objc
    private func actionButtonTapped(sender _: Any?) {
        action?()
    }
}
