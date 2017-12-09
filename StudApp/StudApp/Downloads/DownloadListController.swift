//
//  DownloadListController.swift
//  StudApp
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import QuickLook
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

        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.tableHeaderView = nil

        registerForPreviewing(with: self, sourceView: tableView)

        let shareItem = UIMenuItem(title: "Share".localized, action: #selector(FileCell.shareDocument(sender:)))
        UIMenuController.shared.menuItems = [shareItem]
        UIMenuController.shared.update()

        updateEmptyView()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.updateEmptyView()
        }, completion: nil)
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
            let documentUrl = file.documentUrl(inProviderDirectory: true)
            guard let data = try? Data(contentsOf: documentUrl, options: .mappedIfSafe) else { return }
            UIPasteboard.general.setData(data, forPasteboardType: file.typeIdentifier)
        default:
            break
        }
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = viewModel[rowAt: indexPath]
        let previewController = PreviewController()
        previewController.prepareDependencies(for: .preview(file))
        present(previewController, animated: true, completion: nil)
    }

    // MARK: - Data Source Delegate

    func dataDidChange<Source>(in _: Source) {
        tableView.endUpdates()
        updateEmptyView()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        prepareForRoute(using: segue, sender: sender)
    }

    // MARK: - User Interface

    @IBOutlet var emptyView: UIView!

    @IBOutlet var emptyViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var emptyViewTitleLabel: UILabel!

    @IBOutlet weak var emptyViewSubtitleLabel: UILabel!

    private func updateEmptyView() {
        guard view != nil else { return }

        emptyViewTitleLabel.text = "It Looks Like There Are No Downloads Yet".localized
        emptyViewSubtitleLabel.text = "Open the app \"Files\" to get started.".localized

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
}

// MARK: - Search Results Updating

extension DownloadListController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.fetch(searchTerm: searchController.searchBar.text)
        tableView.reloadData()
    }
}

// MARK: - Table View Drag Delegate

extension DownloadListController: UITableViewDragDelegate {
    private func items(forIndexPath indexPath: IndexPath) -> [UIDragItem] {
        let file = viewModel[rowAt: indexPath]
        guard let itemProvider = NSItemProvider(contentsOf: file.documentUrl(inProviderDirectory: true)) else { return [] }
        return [UIDragItem(itemProvider: itemProvider)]
    }

    func tableView(_: UITableView, itemsForBeginning _: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return items(forIndexPath: indexPath)
    }

    func tableView(_: UITableView, itemsForAddingTo _: UIDragSession, at indexPath: IndexPath,
                   point _: CGPoint) -> [UIDragItem] {
        return items(forIndexPath: indexPath)
    }
}

// MARK: - Document Previewing

extension DownloadListController: UIViewControllerPreviewingDelegate {
    func previewingContext(_: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        let file = viewModel[rowAt: indexPath]
        let previewController = PreviewController()
        previewController.prepareDependencies(for: .preview(file))
        return previewController
    }

    func previewingContext(_: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit, animated: true, completion: nil)
    }
}
