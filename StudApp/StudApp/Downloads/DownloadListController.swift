//
//  DownloadListController.swift
//  StudApp
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class DownloadListController: UITableViewController, DataSourceDelegate {
    private var viewModel: DownloadListViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = DownloadListViewModel()
        viewModel.delegate = self
        viewModel.fetch()

        navigationItem.title = "Downloads".localized

        navigationController?.navigationBar.prefersLargeTitles = true

        let shareItem = UIMenuItem(title: "Share".localized, action: #selector(FileCell.shareDocument(sender:)))
        UIMenuController.shared.menuItems = [shareItem]
        UIMenuController.shared.update()
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in _: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FileCell.typeIdentifier, for: indexPath)
        (cell as? FileCell)?.file = viewModel[rowAt: indexPath]
        (cell as? FileCell)?.documentController?.delegate = self
        return cell
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel[sectionAt: section]
    }

    override func sectionIndexTitles(for _: UITableView) -> [String]? {
        return viewModel.sectionIndexTitles
    }

    override func tableView(_: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return viewModel.section(forSectionIndexTitle: title, at: index)
    }

    // MARK: - Table View Delegate

    override func tableView(_: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        func removeDownloadHandler(action _: UIContextualAction, view _: UIView, handler: @escaping (Bool) -> Void) {
            let file = viewModel[rowAt: indexPath]
            let success = viewModel.removeDownload(file)
            handler(success)
        }

        let removeDownloadAction = UIContextualAction(style: .destructive, title: "Remove Download".localized,
                                                      handler: removeDownloadHandler)
        return UISwipeActionsConfiguration(actions: [removeDownloadAction])
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FileCell else { return }
        cell.documentController?.presentPreview(animated: true)
    }

    override func tableView(_: UITableView, shouldShowMenuForRowAt _: IndexPath) -> Bool {
        return true
    }

    override func tableView(_: UITableView, canPerformAction action: Selector, forRowAt _: IndexPath,
                            withSender _: Any?) -> Bool {
        switch action {
        case #selector(FileCell.shareDocument(sender:)):
            return true
        default:
            return false
        }
    }

    override func tableView(_: UITableView, performAction _: Selector, forRowAt _: IndexPath, withSender _: Any?) {
    }

    // MARK: - User Interaction

    @IBAction
    func userButtonTapped(_ sender: Any) {
        (tabBarController as? MainController)?.userButtonTapped(sender)
    }
}

// MARK: - Document Interaction Controller Conformance

extension DownloadListController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_: UIDocumentInteractionController) -> UIViewController {
        return self
    }

    func documentInteractionControllerViewForPreview(_: UIDocumentInteractionController) -> UIView? {
        guard let indexPath = tableView.indexPathForSelectedRow,
            let cell = tableView.cellForRow(at: indexPath) as? FileCell else { return nil }
        return cell.iconView
    }
}
