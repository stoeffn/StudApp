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
    private var htmlContentService: HtmlContentService!
    private var viewModel: OrganizationListViewModel!
    private var observations = [NSKeyValueObservation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        contextService = ServiceContainer.default[ContextService.self]
        htmlContentService = ServiceContainer.default[HtmlContentService.self]

        navigationItem.title = "Choose Your Organization".localized
        navigationItem.hidesBackButton = true
        navigationItem.backBarButtonItem?.title = "Organizations".localized
        navigationItem.rightBarButtonItem?.accessibilityLabel = "More".localized

        if contextService.currentTarget != .fileProviderUI {
            navigationItem.leftBarButtonItem = nil
        }

        tableView.tableHeaderView?.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView?.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        tableView.tableHeaderView?.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        tableView.tableHeaderView?.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        tableView.tableHeaderView?.layoutIfNeeded()
        tableView.tableHeaderView = tableView.tableHeaderView

        disclaimerLabel.text = "Choose the organization, university, or company you would like to sign into.".localized

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
        default:
            prepareForRoute(using: segue, sender: sender)
        }
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.error == nil ? viewModel.numberOfRows : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let error = viewModel.error {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.typeIdentifier,
                                                           for: indexPath) as? ActionCell else { fatalError() }
            cell.titleLabel.text = "Error Loading Organizations".localized
            cell.subtitleLabel.text = error.localizedDescription
            cell.actionButton.setTitle("Retry".localized, for: .normal)
            cell.action = { [unowned self] in self.viewModel.update() }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: OrganizationCell.typeIdentifier, for: indexPath)
        (cell as? OrganizationCell)?.organization = viewModel[rowAt: indexPath.row]
        return cell
    }

    override func tableView(_: UITableView, titleForFooterInSection _: Int) -> String? {
        return "If are an administrator and would like to add your organization, please contact me at %@."
            .localized(App.feedbackMailAddress)
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - User Interface

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
