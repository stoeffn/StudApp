//
//  OrganizationListController.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 26.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import FileProviderUI
import SafariServices
import StudKit

final class OrganizationListController: UITableViewController, Routable, DataSourceSectionDelegate {
    private var contextService: ContextService!
    private var viewModel: OrganizationListViewModel!
    private var completionHandler: ((SignInResult) -> Void)?

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        contextService = ServiceContainer.default[ContextService.self]

        viewModel.stateChanged = updateUserInterface
        viewModel.fetch()

        navigationItem.title = "Choose Your Organization".localized
        navigationItem.hidesBackButton = true
        navigationItem.backBarButtonItem?.title = "Organizations".localized

        if contextService.currentTarget != .fileProviderUI {
            navigationItem.leftBarButtonItem = nil
        }
    }

    func prepareDependencies(for route: Routes) {
        guard case let .signIn(handler) = route else { fatalError() }
        viewModel = OrganizationListViewModel()
        completionHandler = handler
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        switch viewModel.state {
        case .loading, .failure:
            return 1
        case let .success(organizations):
            return organizations.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.state {
        case .loading:
            return tableView.dequeueReusableCell(withIdentifier: ActivityIndicatorCell.typeIdentifier, for: indexPath)
        case let .failure(error):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.typeIdentifier,
                                                           for: indexPath) as? ActionCell else { fatalError() }
            cell.titleLabel.text = "Error Loading Organizations".localized
            cell.subtitleLabel.text = error
            cell.actionButton.setTitle("Retry".localized, for: .normal)
            cell.action = { self.viewModel.fetch() }
            return cell
        case let .success(organizations):
            let cell = tableView.dequeueReusableCell(withIdentifier: OrganizationCell.typeIdentifier, for: indexPath)
            (cell as? OrganizationCell)?.organization = organizations[indexPath.row]
            return cell
        }
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch sender {
        case let organizationCell as OrganizationCell:
            prepare(for: .signIntoOrganization(organizationCell.organization, completion: signedIntoOrganization),
                    destination: segue.destination)
        default:
            prepareForRoute(using: segue, sender: sender)
        }
    }

    // MARK: - User Interface

    @IBOutlet var cancelButton: UIBarButtonItem!

    private func updateUserInterface(_: OrganizationListViewModel.State? = nil) {
        UIView.transition(with: tableView, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        }, completion: nil)
    }

    // MARK: - User Interaction

    @IBAction
    func moreButtonTapped(_ sender: Any) {
        func showAboutView(_: UIAlertAction) {
            let route = Routes.about {
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }
            performSegue(withRoute: route)
        }

        func showHelpView(_: UIAlertAction) {
            guard let url = App.Links.help else { return }
            let controller = SFSafariViewController(url: url)
            controller.preferredControlTintColor = UI.Colors.tint
            present(controller, animated: true, completion: nil)
        }

        let barButtonItem = sender as? UIBarButtonItem

        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.popoverPresentationController?.barButtonItem = barButtonItem
        controller.addAction(UIAlertAction(title: "About".localized, style: .default, handler: showAboutView))
        controller.addAction(UIAlertAction(title: "Help".localized, style: .default, handler: showHelpView))
        controller.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }

    @IBAction
    func cancelButtonTapped(_: Any) {
        completionHandler?(.none)
    }

    // MARK: - Completion Handlers

    private func signedIntoOrganization(result: SignInResult) {
        presentedViewController?.dismiss(animated: true) {
            if result == .signedIn {
                self.completionHandler?(result)
            }
        }
    }
}
