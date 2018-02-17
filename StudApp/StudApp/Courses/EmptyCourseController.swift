//
//  EmptyCourseController.swift
//  StudApp
//
//  Created by Steffen Ryll on 12.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit

final class EmptyCourseController: UIViewController {

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "No Course".localized
        subtitleLabel.text = "Select a course on the left to get started.".localized
    }

    // MARK: - User Interface

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var subtitleLabel: UILabel!
}
