//
//  VerificationController.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class VerificationController: UIViewController, Routable {
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Verifying Your Purchase…".localized
    }

    // MARK: - User Interface

    @IBOutlet weak var titleLabel: UILabel!
}
