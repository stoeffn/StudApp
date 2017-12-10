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

        registerForPreviewing(with: self, sourceView: tableView)

        navigationItem.title = "Downloads".localized

        tableView.tableHeaderView = nil

        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true

            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false

            tableView.dragDelegate = self
            tableView.dragInteractionEnabled = true
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }

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

    @available(iOS 11.0, *)
    override func tableView(_: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        func removeHandler(action _: UIContextualAction, view _: UIView, handler: @escaping (Bool) -> Void) {
            let file = viewModel[rowAt: indexPath]
            let success = viewModel.removeDownload(file)
            handler(success)
        }

        let removeAction = UIContextualAction(style: .destructive, title: "Remove".localized, handler: removeHandler)
        removeAction.backgroundColor = UI.Colors.studRed

        return UISwipeActionsConfiguration(actions: [removeAction])
    }

    override func tableView(_: UITableView, shouldShowMenuForRowAt _: IndexPath) -> Bool {
        return true
    }

    override func tableView(_: UITableView, canPerformAction action: Selector, forRowAt _: IndexPath,
                            withSender _: Any?) -> Bool {
        switch action {
        case #selector(CustomMenuItems.share(_:)), #selector(CustomMenuItems.remove(_:)):
            return true
        default:
            return false
        }
    }

    override func tableView(_: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender _: Any?) {
        return
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
        emptyViewSubtitleLabel.text = "Open the app \"Files\" or browse your courses to get started.".localized

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

@available(iOS 11.0, *)
extension DownloadListController: UITableViewDragDelegate {
    private func items(forIndexPath indexPath: IndexPath) -> [UIDragItem] {
        let file = viewModel[rowAt: indexPath]
        guard let itemProvider = NSItemProvider(contentsOf: file.localUrl(inProviderDirectory: true)) else { return [] }
        itemProvider.suggestedName = file.sanitizedTitleWithExtension
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
