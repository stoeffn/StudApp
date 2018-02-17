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
            titleLabel.text = semester.title
            monthRangeLabel.text = semester.monthRange
            isHiddenSwitch.isOn = !semester.state.isHidden
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
}
