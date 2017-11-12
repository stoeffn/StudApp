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
            dateRangeLabel.text = semester?.beginDate.description
        }
    }

    // MARK: - User Interface

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var dateRangeLabel: UILabel!

    @IBOutlet weak var isHiddenSwitch: UISwitch!
}
