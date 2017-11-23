//
//  FileCell.swift
//  StudApp
//
//  Created by Steffen Ryll on 23.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class FileCell: UITableViewCell {
    // MARK: - Life Cycle

    var file: File? {
        didSet {
            titleLabel?.text = file?.title
        }
    }

    // MARK: - User Interface

    @IBOutlet weak var titleLabel: UILabel?
}
