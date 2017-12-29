//
//  SettingsController.swift
//  StudApp
//
//  Created by Steffen Ryll on 24.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class SettingsController: UITableViewController, Routable {
    private var viewModel: SettingsViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = SettingsViewModel()

        navigationItem.title = "Settings".localized

        downloadsCell.textLabel?.text = "Downloads".localized
        downloadsCell.detailTextLabel?.text = viewModel.sizeOfDownloadsDirectory?.formattedAsByteCount ?? "—"
        removeDownloadsCell.textLabel?.text = "Remove All Downloads".localized

        signOutCell.textLabel?.text = "Sign Out".localized
    }

    // MARK: - Table View Data Source

    private enum Sections: Int {
        case documents, account
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .documents?: return "Documents".localized
        case .account?, nil: return nil
        }
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .documents?:
            return [
                "This accounts for the combined sizes of all documents that you have downloaded.".localized,
                "They are not backed up by iTunes or iCloud.".localized,
            ].joined(separator: " ")
        case .account?, nil:
            return nil
        }
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.cellForRow(at: indexPath) {
        case removeDownloadsCell?:
            try? viewModel.removeAllDownloads()
            downloadsCell.detailTextLabel?.text = viewModel.sizeOfDownloadsDirectory?.formattedAsByteCount ?? "—"
            tableView.deselectRow(at: indexPath, animated: true)
        case signOutCell?:
            viewModel.signOut()
            dismiss(animated: true, completion: nil)
            presentingViewController?.performSegue(withRoute: .signIn)
        default:
            break
        }
    }

    // MARK: - User Interface

    @IBOutlet weak var downloadsCell: UITableViewCell!

    @IBOutlet weak var removeDownloadsCell: UITableViewCell!

    @IBOutlet weak var signOutCell: UITableViewCell!

    // MARK: - User Interaction

    @IBAction
    func doneButtonTapped(_: Any) {
        dismiss(animated: true, completion: nil)
    }
}
