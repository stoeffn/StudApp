//
//  OrganizationListController.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit

final class OrganizationListController: UITableViewController, Routable, DataSourceSectionDelegate {
    private var viewModel: OrganizationListViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = OrganizationListViewModel()
        viewModel.delegate = self
        viewModel.fetch { result in
            print(result.error)
        }

        navigationItem.title = "Choose Your Organization".localized
    }

    func prepareDependencies(for _: Routes) {
        // TODO: Implement
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
}
