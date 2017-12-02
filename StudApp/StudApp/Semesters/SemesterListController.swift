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

        navigationItem.title = "Semesters".localized

        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.tableHeaderView = nil

        updateEmptyView()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.updateEmptyView()
        }, completion: nil)
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

    // MARK: - Data Source Delegate

    func dataDidChange<Source>(in _: Source) {
        tableView.endUpdates()
        updateEmptyView()
    }

    // MARK: - User Interface

    @IBOutlet var emptyView: UIView!

    @IBOutlet var emptyViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var emptyViewTitleLabel: UILabel!

    @IBOutlet weak var emptyViewSubtitleLabel: UILabel!

    @IBOutlet weak var emptyViewActionButton: UIButton!

    private func updateEmptyView() {
        guard view != nil else { return }

        emptyViewTitleLabel.text = "It Looks Like There Are No Semester".localized
        emptyViewSubtitleLabel.text = "You can try to reload the semesters from Stud.IP.".localized

        tableView.backgroundView = viewModel.isEmpty ? emptyView : nil
        tableView.separatorStyle = viewModel.isEmpty ? .none : .singleLine
        tableView.bounces = !viewModel.isEmpty

        if let navigationBarHeight = navigationController?.navigationBar.bounds.size.height {
            emptyViewTopConstraint.constant = navigationBarHeight * 2 + 32
        }
    }

    // MARK: - User Interaction

    @IBAction
    func userButtonTapped(_ sender: Any) {
        (tabBarController as? MainController)?.userButtonTapped(sender)
    }

    @IBAction
    func emptyViewActionButtonTapped(_: Any) {
        viewModel.update(enforce: true)
    }
}
