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
    // MARK: - Life Cycle

    private var contextService: ContextService!
    private var viewModel: OrganizationListViewModel!
    private var observations = [NSKeyValueObservation]()
    private var completion: ((SignInResult) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()

        contextService = ServiceContainer.default[ContextService.self]

        navigationItem.title = "Choose Your Organization".localized
        navigationItem.hidesBackButton = true
        navigationItem.backBarButtonItem?.title = "Organizations".localized

        if contextService.currentTarget != .fileProviderUI {
            navigationItem.leftBarButtonItem = nil
        }

        observations = [
            viewModel.observe(\.isUpdating) { [weak self] (_, _) in
                guard let isUpdating = self?.viewModel.isUpdating else { return }
                self?.navigationItem.setActivityIndicatorHidden(!isUpdating)
            },
            viewModel.observe(\.error) { [weak self] (_, _) in
                self?.tableView.reloadData()
            }
        ]

        viewModel.fetch()
        viewModel.update()
    }

    func prepareDependencies(for route: Routes) {
        guard case let .signIn(completion) = route else { fatalError() }
        self.completion = completion

        viewModel = OrganizationListViewModel()
        viewModel.delegate = self
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.error == nil ? viewModel.numberOfRows : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let errorMessage = viewModel.errorMessage {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.typeIdentifier,
                                                           for: indexPath) as? ActionCell else { fatalError() }
            cell.titleLabel.text = "Error Loading Organizations".localized
            cell.subtitleLabel.text = errorMessage
            cell.actionButton.setTitle("Retry".localized, for: .normal)
            cell.action = { [unowned self] in self.viewModel.update() }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: OrganizationCell.typeIdentifier, for: indexPath)
        (cell as? OrganizationCell)?.organization = viewModel[rowAt: indexPath.row]
        return cell
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch sender {
        case let organizationCell as OrganizationCell:
            prepare(for: route(forSigningInto: organizationCell.organization), destination: segue.destination)
        default:
            prepareForRoute(using: segue, sender: sender)
        }
    }

    private func route(forSigningInto organization: Organization) -> Routes {
        return .signIntoOrganization(organization) { result in
            self.presentedViewController?.dismiss(animated: true) {
                guard result == .signedIn else { return }
                self.completion(result)
            }
        }
    }

    private func routeForAbout() -> Routes {
        return .about {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - User Interface

    @IBOutlet var cancelButton: UIBarButtonItem!

    func controllerForMore(at barButtonItem: UIBarButtonItem? = nil) -> UIViewController {
        let actions = [
            UIAlertAction(title: "About".localized, style: .default) { _ in
                self.performSegue(withRoute: self.routeForAbout())
            },
            UIAlertAction(title: "Help".localized, style: .default) { _ in
                guard let controller = self.controllerForHelp() else { return }
                self.present(controller, animated: true, completion: nil)
            },
            UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil),
        ]

        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.popoverPresentationController?.barButtonItem = barButtonItem
        actions.forEach(controller.addAction)
        return controller
    }

    private func controllerForHelp() -> UIViewController? {
        guard let url = App.Links.help else { return nil }

        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = UI.Colors.tint
        return controller
    }

    // MARK: - User Interaction

    @IBAction
    func moreButtonTapped(_ sender: Any) {
        present(controllerForMore(at: sender as? UIBarButtonItem), animated: true, completion: nil)
    }

    @IBAction
    func cancelButtonTapped(_: Any) {
        completion(.none)
    }
}
