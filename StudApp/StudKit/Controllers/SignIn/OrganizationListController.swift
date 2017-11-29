//
//  OrganizationListController.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import FileProviderUI
import UIKit

final class OrganizationListController: UITableViewController, Routable, DataSourceSectionDelegate {
    private var contextService: ContextService!
    private var viewModel: OrganizationListViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        contextService = ServiceContainer.default[ContextService.self]

        viewModel = OrganizationListViewModel()
        viewModel.stateChanged = { _ in self.tableView.reloadData() }
        viewModel.fetch()

        navigationItem.title = "Choose Your Organization".localized
        navigationItem.backBarButtonItem?.title = "Organizations".localized

        if contextService.currentTarget != .fileProviderUI {
            navigationItem.leftBarButtonItem = nil
        }
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
            cell.subtitleLabel.text = error.localizedDescription
            cell.action = { self.viewModel.fetch() }
            return cell
        case let .success(organizations):
            let cell = tableView.dequeueReusableCell(withIdentifier: OrganizationCell.typeIdentifier, for: indexPath)
            (cell as? OrganizationCell)?.organization = organizations[indexPath.row]
            return cell
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch sender {
        case let organizationCell as OrganizationCell:
            prepare(for: .signInToOrganization(organizationCell.organization), destination: segue.destination)
        default:
            prepareForRoute(using: segue, sender: sender)
        }
    }

    // MARK: - User Interface

    @IBOutlet weak var cancelButton: UIBarButtonItem!

    // MARK: - User Intercation

    @IBAction
    func cancelButtonTapped(_: Any) {
        contextService.extensionContext?.cancelRequest(withError: "Canceled")
    }
}
