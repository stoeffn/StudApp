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
    private var completion: ((SettingsResult) -> Void)?

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = SettingsViewModel()

        navigationItem.title = "Settings".localized

        downloadsCell.textLabel?.text = "Downloads".localized
        downloadsCell.detailTextLabel?.text = viewModel.sizeOfDownloadsDirectory?.formattedAsByteCount ?? "—"
        removeAllDownloadsCell.textLabel?.text = "Remove All Downloads".localized

        signOutCell.textLabel?.text = "Sign Out".localized
    }

    func prepareDependencies(for route: Routes) {
        guard case let .settings(handler) = route else { fatalError() }
        completion = handler
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
        case removeAllDownloadsCell?:
            removeAllDownloads()
        case signOutCell?:
            signOut()
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - User Interface

    @IBOutlet weak var downloadsCell: UITableViewCell!

    @IBOutlet weak var removeAllDownloadsCell: UITableViewCell!

    @IBOutlet weak var signOutCell: UITableViewCell!

    // MARK: - User Interaction

    @IBAction
    func doneButtonTapped(_: Any) {
        completion?(.none)
    }

    private func removeAllDownloads() {
        let confirmation = UIAlertController(confirmationWithAction: removeAllDownloadsCell.textLabel?.text,
                                             sourceView: removeAllDownloadsCell) { _ in
            try? self.viewModel.removeAllDownloads()
            let downloadsSizeText = self.viewModel.sizeOfDownloadsDirectory?.formattedAsByteCount ?? "—"
            self.removeAllDownloadsCell.detailTextLabel?.text = downloadsSizeText
        }
        present(confirmation, animated: true, completion: nil)
    }

    private func signOut() {
        let confirmation = UIAlertController(confirmationWithAction: signOutCell.textLabel?.text,
                                             sourceView: signOutCell) { _ in
            self.viewModel.signOut()
            self.completion?(.signedOut)
        }
        present(confirmation, animated: true, completion: nil)
    }
}
