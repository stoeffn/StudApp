//
//  DownloadListController.swift
//  StudApp
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import QuickLook
import StudKit
import StudKitUI

final class DownloadListController: UITableViewController, DataSourceDelegate {
    private var viewModel: DownloadListViewModel?

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        registerForPreviewing(with: self, sourceView: tableView)

        navigationItem.title = "Downloads".localized

        tableView.register(CourseHeader.self, forHeaderFooterViewReuseIdentifier: CourseHeader.typeIdentifier)

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true

            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false

            tableView.tableHeaderView = nil
            tableView.dragDelegate = self
            tableView.dragInteractionEnabled = true
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }

        updateEmptyView()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in self.updateEmptyView() }, completion: nil)
    }

    // MARK: - Navigation

    func prepareDependencies(for route: Routes) {
        guard case let .downloadList(optionalUser) = route else { fatalError() }

        defer {
            tableView.reloadData()
            updateEmptyView()
        }

        guard let user = optionalUser else { return viewModel = nil }

        viewModel = DownloadListViewModel(user: user)
        viewModel?.delegate = self
        viewModel?.fetch()
    }

    // MARK: - Supporting User Activities

    override func restoreUserActivityState(_ activity: NSUserActivity) {
        guard let file = File.fetch(byObjectId: activity.objectIdentifier), !file.isFolder else {
            let title = "Something went wrong continuing your activity.".localized
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
            return present(alert, animated: true, completion: nil)
        }

        let previewController = PreviewController()
        previewController.prepareContent(for: .preview(for: file, self))
        present(previewController, animated: true, completion: nil)
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in _: UITableView) -> Int {
        return viewModel?.numberOfSections ?? 0
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { fatalError() }
        return viewModel.numberOfRows(inSection: section)
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return CourseHeader.height
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CourseHeader.typeIdentifier)
        guard let course = viewModel?[sectionAt: section] else { fatalError() }
        (header as? CourseHeader)?.course = course
        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FileCell.typeIdentifier, for: indexPath)
        guard let file = viewModel?[rowAt: indexPath] else { fatalError() }
        (cell as? FileCell)?.file = file
        return cell
    }

    override func sectionIndexTitles(for _: UITableView) -> [String]? {
        return viewModel?.sectionIndexTitles
    }

    override func tableView(_: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard let viewModel = viewModel else { fatalError() }
        return viewModel.section(forSectionIndexTitle: title, at: index)
    }

    // MARK: - Table View Delegate

    @available(iOS 11.0, *)
    override func tableView(_: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        func removeHandler(action _: UIContextualAction, view _: UIView, handler: @escaping (Bool) -> Void) {
            guard let viewModel = viewModel else { fatalError() }
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
        guard let viewModel = viewModel else { fatalError() }
        let file = viewModel[rowAt: indexPath]
        let previewController = PreviewController()
        previewController.prepareContent(for: .preview(for: file, self))
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

    @IBOutlet var emptyViewTitleLabel: UILabel!

    @IBOutlet var emptyViewSubtitleLabel: UILabel!

    private(set) lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        return searchController
    }()

    private func updateEmptyView() {
        guard view != nil else { return }

        let isEmpty = viewModel?.isEmpty ?? false

        emptyViewTitleLabel.text = "It Looks Like There Are No Downloads Yet".localized
        emptyViewSubtitleLabel.text = "Open the app \"Files\" or browse your courses to get started.".localized

        tableView.backgroundView = isEmpty ? emptyView : nil
        tableView.separatorStyle = isEmpty ? .none : .singleLine
        tableView.bounces = !isEmpty

        if let navigationBarHeight = navigationController?.navigationBar.bounds.height {
            emptyViewTopConstraint.constant = navigationBarHeight * 2 + 32
        }
    }

    // MARK: - User Interaction

    @IBAction
    func userButtonTapped(_ sender: Any) {
        (tabBarController as? AppController)?.userButtonTapped(sender)
    }
}

// MARK: - Search Results Updating

extension DownloadListController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel?.fetch(searchTerm: searchController.searchBar.text)
        tableView.reloadData()
    }
}

// MARK: - Table View Drag Delegate

@available(iOS 11.0, *)
extension DownloadListController: UITableViewDragDelegate {
    private func itemProviders(forIndexPath indexPath: IndexPath) -> [NSItemProvider] {
        guard
            let file = viewModel?[rowAt: indexPath],
            let itemProvider = NSItemProvider(contentsOf: file.localUrl(in: .fileProvider))
        else { return [] }

        itemProvider.suggestedName = file.name
        return [itemProvider]
    }

    func tableView(_: UITableView, itemsForBeginning _: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return itemProviders(forIndexPath: indexPath).map(UIDragItem.init)
    }

    func tableView(_: UITableView, itemsForAddingTo _: UIDragSession, at indexPath: IndexPath,
                   point _: CGPoint) -> [UIDragItem] {
        return itemProviders(forIndexPath: indexPath).map(UIDragItem.init)
    }
}

// MARK: - Document Previewing

extension DownloadListController: UIViewControllerPreviewingDelegate, QLPreviewControllerDelegate {
    func previewingContext(_: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard
            let indexPath = tableView.indexPathForRow(at: location),
            let file = viewModel?[rowAt: indexPath]
        else { return nil }

        let previewController = PreviewController()
        previewController.prepareContent(for: .preview(for: file, self))
        return previewController
    }

    func previewingContext(_: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit, animated: true, completion: nil)
    }

    func previewController(_: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        guard
            let file = item as? File,
            let indexPath = viewModel?.indexPath(for: file),
            let cell = tableView.cellForRow(at: indexPath) as? FileCell
        else { return nil }
        return cell.iconView
    }
}
