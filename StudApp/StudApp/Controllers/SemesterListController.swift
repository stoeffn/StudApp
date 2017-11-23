//
//  SemesterListController.swift
//  StudApp
//
//  Created by Steffen Ryll on 12.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class SemesterListController: UITableViewController, DataSourceSectionDelegate {
    private var viewModel: SemesterListViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = SemesterListViewModel()
        viewModel.delegate = self
        viewModel.fetch()
        viewModel.update()

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
        let cell = tableView.dequeueReusableCell(withIdentifier: SemesterCell.typeIdentifier, for: indexPath)
        (cell as? SemesterCell)?.semester = viewModel[rowAt: indexPath.row]
        return cell
    }

    // MARK: - User Interaction

    @IBAction
    func userButtonTapped(_ sender: Any) {
        func signOut(_: UIAlertAction) {
            viewModel.signOut()
            tabBarController?.performSegue(withRoute: Segues.signIn)
        }

        guard let barButtonItem = sender as? UIBarButtonItem else { return }

        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.popoverPresentationController?.barButtonItem = barButtonItem
        controller.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: signOut))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
}
