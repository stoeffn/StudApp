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

import FileProviderUI
import SafariServices
import StudKit

final class OrganizationListController: UITableViewController, Routable, DataSourceSectionDelegate {

    // MARK: - Life Cycle

    private var htmlContentService: HtmlContentService!
    private var viewModel: OrganizationListViewModel!
    private var observations = [NSKeyValueObservation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        htmlContentService = ServiceContainer.default[HtmlContentService.self]

        navigationItem.hidesBackButton = true
        navigationItem.backBarButtonItem?.title = "Organizations".localized
        navigationItem.rightBarButtonItem?.accessibilityLabel = "More".localized

        if Targets.current != .fileProviderUI {
            navigationItem.leftBarButtonItem = nil
        }

        tableView.tableHeaderView?.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView?.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        tableView.tableHeaderView?.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        tableView.tableHeaderView?.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        tableView.tableHeaderView?.layoutIfNeeded()
        tableView.tableHeaderView = tableView.tableHeaderView

        welcomeLabel.text = "Welcome to StudApp".localized
        welcomeLabel.font = UIFont.preferredFont(forTextStyle: .title1).bold

        disclaimerLabel.text = """
        Choose your university, company, or organization to sign in and access your courses, documents, announcements, and events.
        """.localized

        observations = [
            viewModel.observe(\.isUpdating) { [weak self] _, _ in
                guard let isUpdating = self?.viewModel.isUpdating else { return }
                self?.navigationItem.setActivityIndicatorHidden(!isUpdating)
            },
            viewModel.observe(\.error) { [weak self] _, _ in
                self?.tableView.reloadData()
            },
        ]

        viewModel.fetch()
        viewModel.update()
    }

    deinit {
        observations.removeAll()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.tableView.tableHeaderView?.layoutIfNeeded()
            self.tableView.tableHeaderView = self.tableView.tableHeaderView
        }, completion: nil)
    }

    // MARK: - Navigation

    func prepareContent(for route: Routes) {
        guard case .signIn = route else { fatalError() }
        viewModel = OrganizationListViewModel()
        viewModel.delegate = self
    }

    @IBAction
    func unwindToSignIn(with _: UIStoryboardSegue) {}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch sender {
        case let organizationCell as OrganizationCell:
            prepare(for: .signIntoOrganization(organizationCell.organization), destination: segue.destination)
        case let addOrganizationCell as UITableViewCell where addOrganizationCell.reuseIdentifier == addOrganizationCellIdentifier:
            segue.destination.popoverPresentationController?.delegate = self
            segue.destination.popoverPresentationController?.sourceView = addOrganizationCell
            segue.destination.popoverPresentationController?.sourceRect = addOrganizationCell.bounds
            prepare(for: .disclaimer(withText: addOrganizationDisclaimer), destination: segue.destination)
        default:
            prepareForRoute(using: segue, sender: sender)
        }
    }

    // MARK: - Table View Data Source

    private enum Sections: Int {
        case organizations, addOrganization
    }

    private let addOrganizationCellIdentifier = "AddOrganizationCell"

    private let addOrganizationDisclaimer = [
        "StudApp is free for all kinds of organizations!".localized,
        "",
        "It just needs to be activated by an admin of your organization.".localized,
        "Please contact me at %@ if you would like to support StudApp.".localized(App.feedbackMailAddress),
        "",
        "Note that StudApp requires Stud.IP 4 or newer.".localized
    ].joined(separator: "\n")

    override func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Sections.organizations.rawValue:
            return viewModel.error == nil ? viewModel.numberOfRows : 1
        case Sections.addOrganization.rawValue:
            return 1
        default:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Sections.organizations.rawValue where viewModel.error != nil:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.typeIdentifier,
                                                           for: indexPath) as? ActionCell else { fatalError() }
            cell.titleLabel.text = "Error Loading Organizations".localized
            cell.subtitleLabel.text = viewModel.error?.localizedDescription
            cell.actionButton.setTitle("Retry".localized, for: .normal)
            cell.action = { [unowned self] in self.viewModel.update() }
            return cell
        case Sections.organizations.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: OrganizationCell.typeIdentifier, for: indexPath)
            (cell as? OrganizationCell)?.organization = viewModel[rowAt: indexPath.row]
            return cell
        case Sections.addOrganization.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: addOrganizationCellIdentifier, for: indexPath)
            cell.textLabel?.text = "Add Organization…".localized
            return cell
        default:
            fatalError()
        }
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - User Interface

    @IBOutlet var welcomeLabel: UILabel!

    @IBOutlet var disclaimerLabel: UILabel!

    @IBOutlet var cancelButton: UIBarButtonItem!

    func controllerForMore(at barButtonItem: UIBarButtonItem? = nil) -> UIViewController {
        let actions = [
            UIAlertAction(title: "About".localized, style: .default) { _ in
                self.performSegue(withRoute: .about)
            },
            UIAlertAction(title: "Help".localized, style: .default) { _ in
                self.present(self.htmlContentService.safariViewController(for: App.Urls.help), animated: true, completion: nil)
            },
            UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil),
        ]

        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.popoverPresentationController?.barButtonItem = barButtonItem
        actions.forEach(controller.addAction)
        return controller
    }

    // MARK: - User Interaction

    @IBAction
    func moreButtonTapped(_ sender: Any) {
        present(controllerForMore(at: sender as? UIBarButtonItem), animated: true, completion: nil)
    }

    @IBAction
    func cancelButtonTapped(_: Any) {
        performSegue(withRoute: .unwindToApp)
    }
}

// MARK: - Popover Presentation

extension OrganizationListController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
