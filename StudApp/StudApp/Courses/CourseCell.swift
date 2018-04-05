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

final class CourseCell: UITableViewCell {
    private let contextService = ServiceContainer.default[ContextService.self]

    // MARK: - Life Cycle

    var course: Course! {
        didSet {
            let lecturerNames = course.lecturers
                .map { $0.nameComponents.formatted() }
                .sorted()
                .joined(separator: ", ")

            colorView.backgroundColor = course.color
            titleLabel.text = course.title
            titleLabel.numberOfLines = contextService.prefersAccessibilityContentSize ? 3 : 1
            lecturersLabel.text = lecturerNames

            accessibilityLabel = [course.title, "by %@".localized(lecturerNames)].joined(separator: " ")

            accessibilityCustomActions = [
                UIAccessibilityCustomAction(name: "Color".localized, target: self, selector: #selector(color(_:))),
            ]
        }
    }

    var presentColorPicker: ((CourseCell) -> Void)?

    // MARK: - User Interface

    @IBOutlet var colorView: UIView!

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var lecturersLabel: UILabel!

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        colorView.backgroundColor = course.color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        colorView.backgroundColor = course.color
    }

    // MARK: - User Interaction

    @objc
    func color(_: Any?) -> Bool {
        presentColorPicker?(self)
        return presentColorPicker != nil
    }
}
