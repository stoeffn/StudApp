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
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController?.dimsBackgroundDuringPresentation = false
        navigationItem.searchController?.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false

        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self

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
        removeDownloadAction.backgroundColor = UI.Colors.studRed
        return UISwipeActionsConfiguration(actions: [removeDownloadAction])
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FileCell else { return }

        cell.file.documentController { controller in
            controller.delegate = self
            controller.presentPreview(animated: true)
        }
    }

    override func tableView(_: UITableView, shouldShowMenuForRowAt _: IndexPath) -> Bool {
        return true
    }

    override func tableView(_: UITableView, canPerformAction action: Selector, forRowAt _: IndexPath,
                            withSender _: Any?) -> Bool {
        switch action {
        case #selector(copy(_:)), #selector(FileCell.shareDocument(sender:)):
            return true
        default:
            return false
        }
    }

    override func tableView(_: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender _: Any?) {
        let file = viewModel[rowAt: indexPath]

        switch action {
        case #selector(copy(_:)):
            guard let data = try? Data(contentsOf: file.localUrl, options: .mappedIfSafe) else { return }
            UIPasteboard.general.setData(data, forPasteboardType: file.typeIdentifier)
        default:
            break
        }
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

// MARK: - Search Results Updating

extension DownloadListController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.fetch(searchTerm: searchController.searchBar.text)
        tableView.reloadData()
    }
}

extension DownloadListController: UITableViewDragDelegate {
    private func items(forIndexPath indexPath: IndexPath) -> [UIDragItem] {
        let file = viewModel[rowAt: indexPath]
        guard let itemProvider = NSItemProvider(contentsOf: file.localUrl) else { return [] }
        return [UIDragItem(itemProvider: itemProvider)]
    }

    func tableView(_: UITableView, itemsForBeginning _: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return items(forIndexPath: indexPath)
    }

    func tableView(_: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath,
                   point _: CGPoint) -> [UIDragItem] {
        return items(forIndexPath: indexPath)
    }
}
