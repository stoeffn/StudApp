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

    // MARK: - Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        guard #available(iOS 11.0, *) else { return }
        colorView.accessibilityIgnoresInvertColors = true
    }

    var course: Course! {
        didSet {
            let lecturerNames = course.lecturers
                .map { $0.nameComponents.formatted() }
                .sorted()
                .joined(separator: ", ")

            contentView.alpha = course.isHidden ? 0.5 : 1

            colorView.backgroundColor = course.isHidden ? .darkGray : course.color
            titleLabel.text = course.title
            titleLabel.numberOfLines = Targets.current.prefersAccessibilityContentSize ? 3 : 1
            lecturersLabel.text = lecturerNames

            let hiddenStateDescription = course.isHidden ? Strings.States.hidden.localized : Strings.States.visible.localized
            accessibilityLabel = [
                course.title,
                Strings.Formats.byEntity.localized(lecturerNames),
                UserDefaults.studKit.showsHiddenCourses ? hiddenStateDescription : nil,
            ].compactMap { $0 }.joined(separator: " ")

            accessibilityCustomActions = [
                UIAccessibilityCustomAction(name: Strings.Terms.color.localized, target: self, selector: #selector(color(_:))),
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
        colorView.backgroundColor = course.isHidden ? .darkGray : course.color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        colorView.backgroundColor = course.isHidden ? .darkGray : course.color
    }

    // MARK: - User Interaction

    @objc
    func color(_: Any?) -> Bool {
        presentColorPicker?(self)
        return presentColorPicker != nil
    }

    @objc
    func hide(_: Any?) -> Bool {
        course.isHidden = true
        return true
    }

    @objc
    func show(_: Any?) -> Bool {
        course.isHidden = false
        return true
    }
}
