//
//  CourseCell.swift
//  StudApp
//
//  Created by Steffen Ryll on 23.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class CourseCell: UITableViewCell {

    // MARK: - Life Cycle

    var course: Course! {
        didSet {
            let lecturerNames = course.lecturers
                .map { $0.nameComponents.formatted() }
                .sorted()
                .joined(separator: ", ")

            colorView.backgroundColor = course.color
            titleLabel.text = course.title
            lecturersLabel.text = lecturerNames

            accessibilityLabel = [course.title, "by %@".localized(lecturerNames)].joined(separator: " ")
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
    func color(_: Any?) {
        presentColorPicker?(self)
    }
}
