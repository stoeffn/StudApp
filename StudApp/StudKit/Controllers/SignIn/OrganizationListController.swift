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
        viewModel.delegate = self
        viewModel.fetch { _ in
            self.navigationItem.setActivityIndicatorHidden(true)
        }

        navigationItem.title = "Choose Your Organization".localized
        navigationItem.backBarButtonItem?.title = "Organizations".localized
        navigationItem.setActivityIndicatorHidden(false)

        if contextService.currentTarget != .fileProviderUI {
            navigationItem.leftBarButtonItem = nil
        }
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrganizationCell.typeIdentifier, for: indexPath)
        (cell as? OrganizationCell)?.organization = viewModel[rowAt: indexPath.row]
        return cell
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

    @IBAction func cancelButtonTapped(_ sender: Any) {
        contextService.extensionContext?.cancelRequest(withError: "Canceled")
    }
}
