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
    private var observations: Set<NSKeyValueObservation> = []

    // MARK: - View Model

    var viewModel: SettingsViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            observations = self.observations(for: viewModel)
        }
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Strings.Terms.settings.localized
        downloadsCell.textLabel?.text = Strings.Terms.downloads.localized
        removeAllDownloadsCell.textLabel?.text = Strings.Actions.removeAllDownloads.localized
        notificationsLabel.text = Strings.Actions.allowNotifications.localized
        configureNotificationsCell.textLabel?.text = Strings.Actions.configureInSettings.localized
        signOutCell.textLabel?.text = Strings.Actions.signOut.localized

        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.updateNotificationSettings()
    }

    @objc
    private func willEnterForeground() {
        viewModel?.updateNotificationSettings()
    }

    private func observations(for viewModel: SettingsViewModel) -> Set<NSKeyValueObservation> {
        return [
            viewModel.observe(\.allowsNotifications) { [weak self] (_, _) in
                self?.view.setNeedsLayout()
            },
            viewModel.observe(\.areNotificationsEnabled) { [weak self] (_, _) in
                self?.view.setNeedsLayout()
            },
        ]
    }

    // MARK: - Navigation

    func prepareContent(for route: Routes) {
        guard case .settings = route else { fatalError() }
        viewModel = SettingsViewModel()
    }

    // MARK: - Table View Data Source

    private enum Sections: Int {
        case documents, notifications, account
    }

    func adjustedSectionIndex(forSection section: Int) -> Int {
        let supportsNotifications = viewModel?.supportsNotifications ?? false
        guard !supportsNotifications, section > 0 else { return section }
        return section + 1
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.supportsNotifications ?? false ? 3 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: adjustedSectionIndex(forSection: section))
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: adjustedSectionIndex(forSection: section)) {
        case .documents?: return Strings.Terms.documents.localized
        case .notifications?: return Strings.Terms.notifications.localized
        case .account?, nil: return nil
        }
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Sections(rawValue: adjustedSectionIndex(forSection: section)) {
        case .documents?:
            return Strings.Callouts.downloadsSizeDisclaimer.localized
        case .account?:
            guard let currentUser = User.current else { return nil }
            let currentUserFullName = currentUser.nameComponents.formatted(style: .long)
            return Strings.Callouts.signedInAsAt.localized(currentUserFullName, currentUser.organization.title)
        case .notifications?:
            return Strings.Callouts.notifications.localized
        case nil:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let adjustedIndexPath = IndexPath(row: indexPath.row, section: adjustedSectionIndex(forSection: indexPath.section))
        return super.tableView(tableView, cellForRowAt: adjustedIndexPath)
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.cellForRow(at: indexPath) {
        case removeAllDownloadsCell?:
            removeAllDownloads()
        case configureNotificationsCell?:
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url) { _ in }
        case signOutCell?:
            signOut()
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - User Interface

    override func viewWillLayoutSubviews() {
        downloadsCell.detailTextLabel?.text = viewModel?.sizeOfDownloadsDirectory?.formattedAsByteCount ?? "—"
        notificationsSwitch.isEnabled = viewModel?.allowsNotifications ?? false
        notificationsSwitch.isOn = viewModel?.areNotificationsEnabled ?? false
    }

    // MARK: Managing Downloads

    @IBOutlet var downloadsCell: UITableViewCell!

    @IBOutlet var removeAllDownloadsCell: UITableViewCell!

    private func removeAllDownloads() {
        let confirmation = UIAlertController(confirmationWithAction: removeAllDownloadsCell.textLabel?.text,
                                             sourceView: removeAllDownloadsCell) { _ in
            try? self.viewModel?.removeAllDownloads()
            self.view.setNeedsLayout()
        }
        present(confirmation, animated: true, completion: nil)
    }

    // MARK: Managing Notifications

    @IBOutlet var notificationsLabel: UILabel!

    @IBOutlet var notificationsSwitch: UISwitch!

    @IBOutlet var configureNotificationsCell: UITableViewCell!

    @IBAction
    func notificationsSwitchValueChanged(_: Any) {
        viewModel?.areNotificationsEnabled.toggle()
    }

    // MARK: Signing Out

    @IBOutlet var signOutCell: UITableViewCell!

    private func signOut() {
        let confirmation = UIAlertController(confirmationWithAction: signOutCell.textLabel?.text, sourceView: signOutCell) { _ in
            self.performSegue(withRoute: .unwindToAppAndSignOut)
        }
        present(confirmation, animated: true, completion: nil)
    }
}
