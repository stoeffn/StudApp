//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

import StudKit
import StudKitUI

final class SettingsController: UITableViewController, Routable {
    private var viewModel: SettingsViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Settings".localized

        downloadsCell.textLabel?.text = "Downloads".localized
        removeAllDownloadsCell.textLabel?.text = "Remove All Downloads".localized

        signOutCell.textLabel?.text = "Sign Out".localized

        updateDownloadsSize()
    }

    // MARK: - Navigation

    func prepareContent(for route: Routes) {
        guard case .settings = route else { fatalError() }
        viewModel = SettingsViewModel()
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
        case .account?:
            guard let currentUser = User.current else { return nil }
            let currentUserFullName = currentUser.nameComponents.formatted(style: .long)
            return "Signed in as %@ at %@".localized(currentUserFullName, currentUser.organization.title)
        case nil:
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

    @IBOutlet var downloadsCell: UITableViewCell!

    @IBOutlet var removeAllDownloadsCell: UITableViewCell!

    @IBOutlet var signOutCell: UITableViewCell!

    private func updateDownloadsSize() {
        downloadsCell.detailTextLabel?.text = viewModel.sizeOfDownloadsDirectory?.formattedAsByteCount ?? "—"
    }

    // MARK: - User Interaction

    @IBAction
    func doneButtonTapped(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    private func removeAllDownloads() {
        let confirmation = UIAlertController(confirmationWithAction: removeAllDownloadsCell.textLabel?.text,
                                             sourceView: removeAllDownloadsCell) { _ in
            try? self.viewModel.removeAllDownloads()
            self.updateDownloadsSize()
        }
        present(confirmation, animated: true, completion: nil)
    }

    private func signOut() {
        let confirmation = UIAlertController(confirmationWithAction: signOutCell.textLabel?.text,
                                             sourceView: signOutCell) { _ in
            self.performSegue(withRoute: .unwindToAppAndSignOut)
        }
        present(confirmation, animated: true, completion: nil)
    }
}
