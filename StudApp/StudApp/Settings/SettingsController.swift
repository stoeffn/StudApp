//
//  SettingsController.swift
//  StudApp
//
//  Created by Steffen Ryll on 24.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class SettingsController: UITableViewController, Routable {
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Settings".localized
    }

    // MARK: - User Interaction

    @IBAction
    func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
