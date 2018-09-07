//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
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

        navigationItem.title = Strings.Terms.downloads.localized
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItems = [moreButton]

        moreButton.accessibilityLabel = Strings.Terms.more.localized
        removeButton.accessibilityLabel = Strings.Actions.remove.localized

        tableView.register(CourseHeader.self, forHeaderFooterViewReuseIdentifier: CourseHeader.typeIdentifier)
        tableView.estimatedRowHeight = FileCell.estimatedHeight
        tableView.estimatedSectionHeaderHeight = CourseHeader.estimatedHeight
        tableView.allowsMultipleSelectionDuringEditing = true

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true

            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false

            tableView.dragDelegate = self
            tableView.dragInteractionEnabled = true
            tableView.tableHeaderView = nil
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateEmptyView()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in self.updateEmptyView() }, completion: nil)
    }

    // MARK: - Navigation

    func prepareContent(for route: Routes) {
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
            let alert = UIAlertController(title: Strings.Errors.userActivityRestoration.localized, message: nil,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Strings.Actions.okay.localized, style: .default, handler: nil))
            return present(alert, animated: true, completion: nil)
        }

        let previewController = PreviewController()
        previewController.prepareContent(for: .preview(for: file, self))
        present(previewController, animated: true, completion: nil)

        ServiceContainer.default[StoreService.self].requestReview()
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in _: UITableView) -> Int {
        return viewModel?.numberOfSections ?? 0
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { fatalError() }
        return viewModel.numberOfRows(inSection: section)
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
    private func removeSwipeAction(for file: File) -> UIContextualAction? {
        guard file.state.isDownloaded else { return nil }
        let action = UIContextualAction(style: .destructive, title: Strings.Actions.remove.localized) { _, _, handler in
            let success = self.viewModel?.removeDownload(file) ?? false
            handler(success)
        }
        action.backgroundColor = UI.Colors.studRed
        return action
    }

    @available(iOS 11.0, *)
    private func markAsNewSwipeAction(for file: File) -> UIContextualAction? {
        guard !file.isFolder, !file.isNew else { return nil }
        let action = UIContextualAction(style: .normal, title: Strings.Actions.markAsNew.localized) { _, _, handler in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { file.isNew = true }
            handler(true)
        }
        action.backgroundColor = file.course.color
        action.image = #imageLiteral(resourceName: "MarkAsNewActionGlypph")
        return action
    }

    @available(iOS 11.0, *)
    private func markAsSeenSwipeAction(for file: File) -> UIContextualAction? {
        guard !file.isFolder, file.isNew else { return nil }
        let action = UIContextualAction(style: .normal, title: Strings.Actions.markAsSeen.localized) { _, _, handler in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { file.isNew = false }
            handler(true)
        }
        action.backgroundColor = file.course.color
        action.image = #imageLiteral(resourceName: "MarkAsSeenActionGlyph")
        return action
    }

    @available(iOS 11.0, *)
    override func tableView(_: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let file = viewModel?[rowAt: indexPath] else { return nil }
        return UISwipeActionsConfiguration(actions: [
            markAsNewSwipeAction(for: file),
            markAsSeenSwipeAction(for: file),
        ].compactMap { $0 })
    }

    @available(iOS 11.0, *)
    override func tableView(_: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let file = viewModel?[rowAt: indexPath] else { return nil }
        return UISwipeActionsConfiguration(actions: [
            removeSwipeAction(for: file),
        ].compactMap { $0 })
    }

    override func tableView(_: UITableView, shouldShowMenuForRowAt _: IndexPath) -> Bool {
        return true
    }

    override func tableView(_: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath,
                            withSender _: Any?) -> Bool {
        guard let viewModel = self.viewModel else { return false }
        let file = viewModel[rowAt: indexPath]

        switch action {
        case #selector(CustomMenuItems.remove(_:)), #selector(CustomMenuItems.share(_:)):
            return file.state.isDownloaded
        case #selector(CustomMenuItems.markAsNew(_:)):
            return !file.isNew && !file.isFolder
        case #selector(CustomMenuItems.markAsSeen(_:)):
            return file.isNew && !file.isFolder
        default:
            return false
        }
    }

    override func tableView(_: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender _: Any?) {
        return
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { fatalError() }
        guard !tableView.isEditing else { return }

        let file = viewModel[rowAt: indexPath]
        let previewController = PreviewController()
        previewController.prepareContent(for: .preview(for: file, self))
        previewController.currentPreviewItemIndex = viewModel.index(for: indexPath)
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

    @IBOutlet var removeButton: UIBarButtonItem!

    @IBOutlet var moreButton: UIBarButtonItem!

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

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        navigationItem.rightBarButtonItems = [editing ? removeButton : moreButton]
    }

    private func updateEmptyView() {
        guard view != nil else { return }

        let isEmpty = viewModel?.isEmpty ?? false

        emptyViewTitleLabel.text = Strings.Callouts.noDownloads.localized
        emptyViewSubtitleLabel.text = Strings.Callouts.noDownloadsSubtitle.localized

        tableView.backgroundView = isEmpty ? emptyView : nil
        tableView.separatorStyle = isEmpty ? .none : .singleLine
        tableView.bounces = !isEmpty

        if let navigationBarHeight = navigationController?.navigationBar.bounds.height {
            emptyViewTopConstraint.constant = navigationBarHeight * 2 + 32
        }
    }

    // MARK: - User Interaction

    @IBAction
    func moreButtonTapped(_ sender: Any) {
        (tabBarController as? AppController)?.userButtonTapped(sender)
    }

    @IBAction
    func removeButtonTapped(_ sender: Any) {
        let controller = UIAlertController(confirmationWithAction: Strings.Actions.remove.localized, barButtonItem: removeButton) { _ in
            self.tableView.indexPathsForSelectedRows?
                .compactMap { self.viewModel?[rowAt: $0] }
                .forEach { self.viewModel?.removeDownload($0) }
        }
        present(controller, animated: true, completion: nil)
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

// MARK: - QuickLook Previewing

extension DownloadListController: QLPreviewControllerDataSource {
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return viewModel?.numberOfRows ?? 0
    }

    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return viewModel![rowAt: index]
    }
}
