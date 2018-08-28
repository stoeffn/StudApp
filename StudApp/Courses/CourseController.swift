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

import MobileCoreServices
import QuickLook
import SafariServices
import StudKit
import StudKitUI

final class CourseController: UITableViewController, Routable {
    private let htmlContentService = ServiceContainer.default[HtmlContentService.self]
    private var viewModel: CourseViewModel!
    private var announcementsViewModel: AnnouncementListViewModel!
    private var fileListViewModel: FileListViewModel!
    private var updateNextEventTimer: Timer?

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        registerForPreviewing(with: self, sourceView: tableView)

        refreshControl?.addTarget(self, action: #selector(refreshControlTriggered(_:)), for: .valueChanged)

        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dragInteractionEnabled = true
        }

        tableView.estimatedRowHeight = FileCell.estimatedHeight
        tableView.tableHeaderView?.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView?.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        tableView.tableHeaderView?.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        tableView.tableHeaderView?.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userActivity = viewModel.course.userActivity
        navigationItem.title = viewModel.course.title

        subtitleLabel.text = viewModel.course.subtitle

        let navigationController = splitViewController?.detailNavigationController ?? self.navigationController
        (navigationController as? BorderlessNavigationController)?.usesDefaultAppearance = true
        (navigationController as? BorderlessNavigationController)?.toolBarView = nil

        tableView.tableHeaderView?.layoutIfNeeded()
        tableView.tableHeaderView = tableView.tableHeaderView
        tableView.reloadSections(IndexSet(integer: Sections.events.rawValue), with: .fade)

        update()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let navigationController = splitViewController?.detailNavigationController ?? self.navigationController
        (navigationController as? BorderlessNavigationController)?.usesDefaultAppearance = false

        updateNextEventTimer?.invalidate()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let navigationController = splitViewController?.detailNavigationController ?? self.navigationController
        (navigationController as? BorderlessNavigationController)?.usesDefaultAppearance = false

        guard self == navigationController?.topViewController else {
            return super.viewWillTransition(to: size, with: coordinator)
        }

        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            let navigationController = self.splitViewController?.detailNavigationController ?? self.navigationController
            (navigationController as? BorderlessNavigationController)?.usesDefaultAppearance = true

            self.tableView.tableHeaderView?.layoutIfNeeded()
            self.tableView.tableHeaderView = self.tableView.tableHeaderView
        }, completion: nil)
    }

    func update(forced: Bool = false) {
        let group = DispatchGroup()

        group.enter()
        announcementsViewModel.update(forced: forced) {
            let placeholderIndex = IndexPath(row: self.announcementsViewModel.numberOfRows, section: Sections.announcements.rawValue)
            self.tableView.update { $0.reloadRows(at: [placeholderIndex], with: .fade) }
            group.leave()
        }

        group.enter()
        fileListViewModel.update(forced: forced) {
            let placeholderIndex = IndexPath(row: self.fileListViewModel.numberOfRows, section: Sections.documents.rawValue)
            self.tableView.update { $0.reloadRows(at: [placeholderIndex], with: .fade) }
            group.leave()
        }

        group.notify(queue: .main) {
            self.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Navigation

    func prepareContent(for route: Routes) {
        guard case let .course(course) = route else { fatalError() }

        viewModel = CourseViewModel(course: course)

        announcementsViewModel = AnnouncementListViewModel(course: course)
        announcementsViewModel.delegate = self
        announcementsViewModel.fetch()

        fileListViewModel = FileListViewModel(container: course)
        fileListViewModel.delegate = self
        fileListViewModel.fetch()
    }

    override func shouldPerformSegue(withIdentifier _: String, sender: Any?) -> Bool {
        guard let cell = sender as? FileCell, !cell.file.isFolder else { return true }
        return false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch sender {
        case let cell as AnnouncementCell:
            prepare(for: .announcement(cell.announcement), destination: segue.destination)
        case let cell as FileCell:
            prepare(for: .folder(cell.file), destination: segue.destination)
        case let cell as UITableViewCell where cell.reuseIdentifier == allEventsCellIdentifier:
            prepare(for: .eventList(for: viewModel.course), destination: segue.destination)
        default:
            prepareForRoute(using: segue, sender: sender)
        }
    }

    // MARK: - Restoration

    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(viewModel.course.objectIdentifier.rawValue, forKey: ObjectIdentifier.typeIdentifier)
        super.encode(with: coder)
    }

    override func decodeRestorableState(with coder: NSCoder) {
        if let restoredObjectIdentifier = coder.decodeObject(forKey: ObjectIdentifier.typeIdentifier) as? String,
            let course = Course.fetch(byObjectId: ObjectIdentifier(rawValue: restoredObjectIdentifier)) {
            prepareContent(for: .course(course))
        }
        super.decodeRestorableState(with: coder)
    }

    // MARK: - Supporting User Activities

    override func updateUserActivityState(_ activity: NSUserActivity) {
        activity.objectIdentifier = viewModel.course.objectIdentifier
    }

    // MARK: - Table View Data Source

    private let emptyCellIdentifier = "EmptyCell"

    private let allEventsCellIdentifier = "AllEventsCell"

    private enum Sections: Int {
        case info, announcements, documents, events, summary
    }

    private func index<Section: DataSourceSection>(for section: Section) -> Sections? {
        let section = section as AnyObject
        if section === announcementsViewModel { return Sections.announcements }
        if section === fileListViewModel { return Sections.documents }
        return nil
    }

    override func numberOfSections(in _: UITableView) -> Int {
        guard viewModel != nil else { return 0 }
        return viewModel.course.summary != nil ? 5 : 4
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .info?:
            return viewModel.numberOfRows
        case .announcements?:
            return announcementsViewModel.numberOfRows + 1
        case .documents?:
            return fileListViewModel.numberOfRows + 1
        case .summary?:
            return 1
        case .events?:
            return 2
        case nil:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .info?:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.typeIdentifier, for: indexPath)
            let row = viewModel[rowAt: indexPath.row]
            cell.imageView?.image = row.glyph
            cell.textLabel?.text = row.title
            cell.detailTextLabel?.text = row.value
            return cell
        case .announcements? where indexPath.row == announcementsViewModel.numberOfRows:
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath)
            let isLoaded = announcementsViewModel.course.state.childFilesUpdatedAt != nil
            cell.textLabel?.text = isLoaded ? Strings.Callouts.noAnnouncements.localized : Strings.States.notLoaded.localized
            return cell
        case .announcements?:
            let cell = tableView.dequeueReusableCell(withIdentifier: AnnouncementCell.typeIdentifier, for: indexPath)
            (cell as? AnnouncementCell)?.announcement = announcementsViewModel[rowAt: indexPath.row]
            (cell as? AnnouncementCell)?.color = viewModel.course.color
            return cell
        case .documents? where indexPath.row == fileListViewModel.numberOfRows:
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath)
            let isLoaded = (fileListViewModel.container as? Course)?.state.childFilesUpdatedAt != nil
            cell.textLabel?.text = isLoaded ? Strings.Callouts.noDocuments.localized : Strings.States.notLoaded.localized
            return cell
        case .documents?:
            let cell = tableView.dequeueReusableCell(withIdentifier: FileCell.typeIdentifier, for: indexPath)
            (cell as? FileCell)?.file = fileListViewModel[rowAt: indexPath.row]
            return cell
        case .events? where indexPath.row == 0 && viewModel.course.nextEvent != nil:
            let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.typeIdentifier, for: indexPath)
            (cell as? EventCell)?.event = viewModel.course.nextEvent
            return cell
        case .events? where indexPath.row == 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath)
            let isLoaded = User.current?.state.eventsUpdatedAt != nil || viewModel.course.state.eventsUpdatedAt != nil
            cell.textLabel?.text = isLoaded ? Strings.Callouts.noUpcomingEvents.localized : Strings.States.notLoaded.localized
            return cell
        case .events?:
            let cell = tableView.dequeueReusableCell(withIdentifier: allEventsCellIdentifier, for: indexPath)
            cell.textLabel?.text = Strings.Terms.allEvents.localized
            cell.detailTextLabel?.text = viewModel.course.state.eventsUpdatedAt != nil ? String(viewModel.course.events.count) : nil
            return cell
        case .summary?:
            let cell = tableView.dequeueReusableCell(withIdentifier: SummaryCell.typeIdentifier, for: indexPath)
            guard let summary = viewModel.course.summary else { return cell }
            (cell as? SummaryCell)?.textView.attributedText = htmlContentService.attributedString(for: summary)
            return cell
        case nil:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch Sections(rawValue: indexPath.section) {
        case .announcements? where indexPath.row == announcementsViewModel.numberOfRows && !announcementsViewModel.isEmpty,
             .documents? where indexPath.row == fileListViewModel.numberOfRows && !fileListViewModel.isEmpty:
            return 0
        default:
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .info?:
            return nil
        case .announcements?:
            return Strings.Terms.announcements.localized
        case .documents?:
            return Strings.Terms.documents.localized
        case .events?:
            guard let nextEvent = viewModel.course.nextEvent else { return Strings.Terms.events.localized }
            return Strings.Formats.nextEventAt.localized(nextEvent.startsAt.formattedAsRelativeDateFromNow)
        case .summary?:
            return Strings.Terms.summary.localized
        case nil:
            fatalError()
        }
    }

    // MARK: - Table View Delegate

    @available(iOS 11.0, *)
    private func markAsNewSwipeAction(for annoucement: Announcement) -> UIContextualAction? {
        guard !annoucement.isNew else { return nil }
        let action = UIContextualAction(style: .normal, title: Strings.Actions.markAsNew.localized) { _, _, handler in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { annoucement.isNew = true }
            handler(true)
        }
        action.backgroundColor = viewModel.course.color
        action.image = #imageLiteral(resourceName: "MarkAsNewActionGlypph")
        return action
    }

    @available(iOS 11.0, *)
    private func markAsSeenSwipeAction(for annoucement: Announcement) -> UIContextualAction? {
        guard annoucement.isNew else { return nil }
        let action = UIContextualAction(style: .normal, title: Strings.Actions.markAsSeen.localized) { _, _, handler in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { annoucement.isNew = false }
            handler(true)
        }
        action.backgroundColor = viewModel.course.color
        action.image = #imageLiteral(resourceName: "MarkAsSeenActionGlyph")
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
        switch Sections(rawValue: indexPath.section) {
        case .announcements? where !announcementsViewModel.isEmpty:
            guard let announcement = announcementsViewModel?[rowAt: indexPath.row] else { return nil }
            return UISwipeActionsConfiguration(actions: [
                markAsNewSwipeAction(for: announcement),
                markAsSeenSwipeAction(for: announcement),
            ].compactMap { $0 })
        case .documents? where !fileListViewModel.isEmpty:
            guard let file = fileListViewModel?[rowAt: indexPath.row] else { return nil }
            return UISwipeActionsConfiguration(actions: [
                markAsNewSwipeAction(for: file),
                markAsSeenSwipeAction(for: file),
            ].compactMap { $0 })
        default:
            return nil
        }
    }

    @available(iOS 11.0, *)
    override func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt _: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [])
    }

    override func tableView(_: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        switch Sections(rawValue: indexPath.section) {
        case .info?,
             .announcements? where !announcementsViewModel.isEmpty,
             .documents? where !fileListViewModel.isEmpty:
            return true
        default:
            return false
        }
    }

    override func tableView(_: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath,
                            withSender _: Any?) -> Bool {
        switch (Sections(rawValue: indexPath.section), action) {
        case (.info?, #selector(copy(_:))),
             (.announcements?, #selector(copy(_:))) where !announcementsViewModel.isEmpty,
             (.summary?, #selector(copy(_:))):
            return true
        case (.announcements?, #selector(CustomMenuItems.markAsNew(_:))) where !announcementsViewModel.isEmpty:
            guard indexPath.row < announcementsViewModel.numberOfRows else { return false }
            return !announcementsViewModel[rowAt: indexPath.row].isNew
        case (.announcements?, #selector(CustomMenuItems.markAsSeen(_:))) where !announcementsViewModel.isEmpty:
            guard indexPath.row < announcementsViewModel.numberOfRows else { return false }
            return announcementsViewModel[rowAt: indexPath.row].isNew
        case (.documents?, #selector(CustomMenuItems.remove(_:))) where !fileListViewModel.isEmpty:
            guard indexPath.row < fileListViewModel.numberOfRows else { return false }
            return fileListViewModel[rowAt: indexPath.row].state.isDownloaded
        case (.documents?, #selector(CustomMenuItems.markAsNew(_:))) where !fileListViewModel.isEmpty:
            guard indexPath.row < fileListViewModel.numberOfRows else { return false }
            let file = fileListViewModel[rowAt: indexPath.row]
            return !file.isNew && !file.isFolder
        case (.documents?, #selector(CustomMenuItems.markAsSeen(_:))) where !fileListViewModel.isEmpty:
            guard indexPath.row < fileListViewModel.numberOfRows else { return false }
            let file = fileListViewModel[rowAt: indexPath.row]
            return file.isNew && !file.isFolder
        default:
            return false
        }
    }

    override func tableView(_: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender _: Any?) {
        switch Sections(rawValue: indexPath.section) {
        case .info? where action == #selector(copy(_:)):
            UIPasteboard.general.string = viewModel[rowAt: indexPath.row].value
        case .announcements?:
            UIPasteboard.general.string = announcementsViewModel[rowAt: indexPath.row].textContent
        case .info?, .documents?:
            break
        case .events?, .summary?, nil:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Sections(rawValue: indexPath.section) {
        case .documents?:
            guard let cell = tableView.cellForRow(at: indexPath) as? FileCell, !cell.file.isFolder else { return }
            PreviewController.controllerForDownloadOrPreview(cell.file, delegate: self) { controller in
                guard let controller = controller else { return }
                self.present(controller, animated: true, completion: nil)
            }
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - User Interface

    @IBOutlet var subtitleLabel: UILabel!

    private func scheduleUpdateTimer(for event: Event) {
        let timer = Timer(fire: event.endsAt, interval: 0, repeats: false) { [weak self] _ in
            self?.tableView.reloadSections(IndexSet(integer: Sections.events.rawValue), with: .fade)
        }
        RunLoop.main.add(timer, forMode: .default)

        updateNextEventTimer?.invalidate()
        updateNextEventTimer = timer
    }

    // MARK: - User Interaction

    @IBAction
    func actionButtonTapped(_: Any) {
        guard let courseUrl = viewModel.course.url else { return }

        let controller = UIActivityViewController(activityItems: [courseUrl],
                                                  applicationActivities: [SafariActivity(controller: self)])
        controller.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(controller, animated: true, completion: nil)
    }

    @IBAction
    func refreshControlTriggered(_: Any) {
        update(forced: true)
    }
}

// MARK: - Data Section Delegate

extension CourseController: DataSourceSectionDelegate {
    func data<Section: DataSourceSection>(changedIn _: Section.Row, at index: Int, change: DataChange<Section.Row, Int>,
                                          in section: Section) {
        guard let sectionIndex = self.index(for: section) else { fatalError() }
        let indexPath = IndexPath(row: index, section: sectionIndex.rawValue)

        switch change {
        case .insert:
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath], with: .fade)
        case let .move(newIndex):
            let newIndexPath = IndexPath(row: newIndex, section: sectionIndex.rawValue)
            tableView.moveRow(at: indexPath, to: newIndexPath)
        }
    }

    func dataDidChange<Section: DataSourceSection>(in _: Section) {
        tableView.endUpdates()
        refreshControl?.endRefreshing()
    }
}

// MARK: - Table View Drag Delegate

@available(iOS 11.0, *)
extension CourseController: UITableViewDragDelegate {
    private func itemProviders(forIndexPath indexPath: IndexPath) -> [NSItemProvider] {
        switch Sections(rawValue: indexPath.section) {
        case .info?:
            guard let data = viewModel[rowAt: indexPath.row].value?.data(using: .utf8) else { return [] }
            return [NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)]
        case .announcements? where !announcementsViewModel.isEmpty:
            return [announcementsViewModel[rowAt: indexPath.row].itemProvider].compactMap { $0 }
        case .documents? where !fileListViewModel.isEmpty:
            return [fileListViewModel[rowAt: indexPath.row].itemProvider].compactMap { $0 }
        default:
            return []
        }
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

extension CourseController: UIViewControllerPreviewingDelegate, QLPreviewControllerDelegate {
    func previewingContext(_: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

        switch Sections(rawValue: indexPath.section) {
        case .documents? where !fileListViewModel.isEmpty:
            let file = fileListViewModel[rowAt: indexPath.row]
            guard !file.isFolder else { return nil }

            if let externalUrl = file.externalUrl, !file.isLocationSecure {
                return ServiceContainer.default[HtmlContentService.self].safariViewController(for: externalUrl)
            }

            let previewController = PreviewController()
            previewController.prepareContent(for: .preview(for: file, self))
            return previewController
        default:
            return nil
        }
    }

    func previewingContext(_: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit, animated: true, completion: nil)
    }

    func previewController(_: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        guard
            let file = item as? File,
            let index = fileListViewModel.index(for: file),
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: Sections.documents.rawValue)) as? FileCell
        else { return nil }
        return cell.iconView
    }
}

// MARK: - Text View Delegate

extension CourseController: UITextViewDelegate {
    public func textView(_: UITextView, shouldInteractWith url: URL, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
        guard let safariController = ServiceContainer.default[HtmlContentService.self].safariViewController(for: url) else {
            return true
        }
        present(safariController, animated: true, completion: nil)
        return false
    }
}
