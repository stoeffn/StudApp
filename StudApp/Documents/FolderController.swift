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

final class FolderController: UITableViewController, Routable {
    private var viewModel: FileListViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        registerForPreviewing(with: self, sourceView: tableView)

        refreshControl?.addTarget(self, action: #selector(refreshControlTriggered(_:)), for: .valueChanged)

        navigationItem.title = viewModel.container.title
        navigationItem.rightBarButtonItem = nil

        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.tableHeaderView = nil
        tableView.estimatedRowHeight = FileCell.estimatedHeight
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        update()
        updateEmptyView()

        if let file = viewModel.container as? File, file.isNew {
            file.isNew = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let navigationController = splitViewController?.detailNavigationController as? BorderlessNavigationController
        UIView.animate(withDuration: 0.1) {
            navigationController?.updateLayout()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in self.updateEmptyView() }, completion: nil)
    }

    func update(forced: Bool = false) {
        viewModel.update(forced: forced) {
            self.updateEmptyView()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { self.refreshControl?.endRefreshing() }
        }
    }

    // MARK: - Navigation

    func prepareContent(for route: Routes) {
        guard case let .folder(folder) = route else { fatalError() }

        viewModel = FileListViewModel(container: folder)
        viewModel.delegate = self
        viewModel.fetch()

        updateEmptyView()
    }

    override func shouldPerformSegue(withIdentifier _: String, sender: Any?) -> Bool {
        switch sender {
        case let cell as FileCell where !cell.file.isFolder:
            return false
        default:
            return true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch sender {
        case let cell as FileCell:
            prepare(for: .folder(cell.file), destination: segue.destination)
        default:
            prepareForRoute(using: segue, sender: sender)
        }
    }

    // MARK: - Restoration

    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(viewModel.container.objectIdentifier.rawValue, forKey: ObjectIdentifier.typeIdentifier)
        super.encode(with: coder)
    }

    override func decodeRestorableState(with coder: NSCoder) {
        if let restoredObjectIdentifier = coder.decodeObject(forKey: ObjectIdentifier.typeIdentifier) as? String,
            let folder = File.fetch(byObjectId: ObjectIdentifier(rawValue: restoredObjectIdentifier)) {
            prepareContent(for: .folder(folder))
        }

        super.decodeRestorableState(with: coder)
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FileCell.typeIdentifier, for: indexPath)
        (cell as? FileCell)?.file = viewModel[rowAt: indexPath.row]
        return cell
    }

    // MARK: - Table View Delegate

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

    override func tableView(_: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let file = viewModel[rowAt: indexPath.row]
        return UISwipeActionsConfiguration(actions: [
            markAsNewSwipeAction(for: file),
            markAsSeenSwipeAction(for: file),
        ].compactMap { $0 })
    }

    override func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt _: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [])
    }

    override func tableView(_: UITableView, shouldShowMenuForRowAt _: IndexPath) -> Bool {
        return true
    }

    override func tableView(_: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath,
                            withSender _: Any?) -> Bool {
        guard indexPath.row < viewModel.numberOfRows else { return false }
        let file = viewModel[rowAt: indexPath.row]

        switch action {
        case #selector(CustomMenuItems.remove(_:)):
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FileCell, !cell.file.isFolder else { return }
        PreviewController.controllerForDownloadOrPreview(cell.file, delegate: self) { controller in
            guard let controller = controller else { return }
            self.present(controller, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Data Source Delegate

    func dataDidChange<Source>(in _: Source) {
        tableView.endUpdates()
        updateEmptyView()
    }

    // MARK: - User Interface

    @IBOutlet var emptyView: UIView!

    @IBOutlet var emptyViewTopConstraint: NSLayoutConstraint!

    @IBOutlet var emptyViewTitleLabel: UILabel!

    @IBOutlet var emptyViewSubtitleLabel: UILabel!

    private func updateEmptyView() {
        guard view != nil else { return }

        let isEmpty = viewModel?.isEmpty ?? false
        let isLoaded = (viewModel.container as? File)?.state.childFilesUpdatedAt != nil

        emptyViewTitleLabel.text = isLoaded ? Strings.Callouts.noFiles.localized : Strings.States.notLoaded.localized
        emptyViewSubtitleLabel.text = isLoaded ? Strings.Callouts.noFilesSubtitle.localized
            : Strings.Callouts.noFilesSubtitle.localized

        tableView.backgroundView = isEmpty ? emptyView : nil
        tableView.separatorStyle = isEmpty ? .none : .singleLine

        if let navigationBarHeight = navigationController?.navigationBar.bounds.height {
            emptyViewTopConstraint.constant = navigationBarHeight * 2 + 32
        }
    }

    // MARK: - User Interaction

    @IBAction
    func actionButtonTapped(_: Any) {
        guard let folder = viewModel.container as? File else { return }
        let url = folder.localUrl(in: .fileProvider)
        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        controller.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(controller, animated: true, completion: nil)
    }

    @objc
    func refreshControlTriggered(_: Any) {
        update(forced: true)
    }
}

// MARK: - Table View Drag Delegate

extension FolderController: UITableViewDragDelegate {
    func tableView(_: UITableView, itemsForBeginning _: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let itemProvider = viewModel[rowAt: indexPath.row].itemProvider else { return [] }
        return [UIDragItem(itemProvider: itemProvider)]
    }

    func tableView(_: UITableView, itemsForAddingTo _: UIDragSession, at indexPath: IndexPath,
                   point _: CGPoint) -> [UIDragItem] {
        guard let itemProvider = viewModel[rowAt: indexPath.row].itemProvider else { return [] }
        return [UIDragItem(itemProvider: itemProvider)]
    }
}

// MARK: - Data Section Delegate

extension FolderController: DataSourceSectionDelegate {
    func dataDidChange<Section: DataSourceSection>(in _: Section) {
        tableView.endUpdates()
        refreshControl?.endRefreshing()
    }
}

// MARK: - Document Previewing

extension FolderController: UIViewControllerPreviewingDelegate, QLPreviewControllerDelegate {
    func previewingContext(_: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        let file = viewModel[rowAt: indexPath.row]
        guard !file.isFolder else { return nil }

        if let externalUrl = file.externalUrl, !file.isLocationSecure {
            return ServiceContainer.default[HtmlContentService.self].safariViewController(for: externalUrl)
        }

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
            let index = viewModel.index(for: file),
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? FileCell
        else { return nil }
        return cell.iconView
    }
}
