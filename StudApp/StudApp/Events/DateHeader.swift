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
