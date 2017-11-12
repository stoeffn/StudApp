//
//  SemesterCell.swift
//  StudApp
//
//  Created by Steffen Ryll on 12.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit
import StudKit

final class SemesterCell: UITableViewCell {
    // MARK: - Life Cycle

    var semester: Semester? {
        didSet {
            titleLabel.text = semester?.title
            monthRangeLabel.text = semester?.monthRange
            isHiddenSwitch.isOn = !(semester?.state.isHidden ?? true)
        }
    }

    // MARK: - User Interface

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var monthRangeLabel: UILabel!

    @IBOutlet weak var isHiddenSwitch: UISwitch!
}
