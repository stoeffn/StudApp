//
//  SemesterCell.swift
//  StudApp
//
//  Created by Steffen Ryll on 12.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class SemesterCell: UITableViewCell {

    // MARK: - Life Cycle

    var semester: Semester! {
        didSet {
            let semesterBeginsAt = semester.beginsAt.formatted(using: .monthAndYear)
            let semesterEndsAt = semester.endsAt.formatted(using: .monthAndYear)

            titleLabel.text = semester.title
            monthRangeLabel.text = "\(semesterBeginsAt) – \(semesterEndsAt)"
            isHiddenSwitch.isOn = !semester.state.isHidden

            accessibilityLabel = "%@, %@ to %@".localized(semester.title, semesterBeginsAt, semesterEndsAt)
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
