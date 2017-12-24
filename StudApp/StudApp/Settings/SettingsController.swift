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

        downloadsCell.textLabel?.text = "Downloads".localized
        removeDownloadsCell.textLabel?.text = "Remove All Downloads".localized

        signOutCell.textLabel?.text = "Sign Out".localized
    }

    // MARK: - Table View Data Source

    private enum Sections: Int {
        case documents, account
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .documents?: return "Documents".localized
        case .account?, nil: return nil
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .documents?:
            return [
                "This accounts for the combined sizes of all documents that you have downloaded.".localized,
                "They are not backed up by iTunes or iCloud.".localized
            ].joined(separator: " ")
        case .account?, nil:
            return nil
        }
    }

    // MARK: - User Interface

    @IBOutlet weak var downloadsCell: UITableViewCell!

    @IBOutlet weak var removeDownloadsCell: UITableViewCell!

    @IBOutlet weak var signOutCell: UITableViewCell!

    // MARK: - User Interaction

    @IBAction
    func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
