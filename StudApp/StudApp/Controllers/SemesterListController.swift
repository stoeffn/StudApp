//
//  SemesterListController.swift
//  StudApp
//
//  Created by Steffen Ryll on 12.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit
import StudKit

final class SemesterListController: UITableViewController, DataSourceSectionDelegate {
    private var viewModel: SemesterListViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = SemesterListViewModel()
        viewModel.delegate = self
        viewModel.fetch()
        viewModel.update { _ in }

        navigationController?.navigationBar.prefersLargeTitles = true
    }

    // MARK: Table View Data Source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SemesterCell.typeIdentifier,
                                                       for: indexPath) as? SemesterCell else {
            fatalError("Cannot dequeue cell with identifier '\(SemesterCell.typeIdentifier)'.")
        }
        cell.semester = viewModel[rowAt: indexPath.row]
        return cell
    }
}
