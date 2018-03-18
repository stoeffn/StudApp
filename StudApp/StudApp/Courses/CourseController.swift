//
//  CourseController.swift
//  StudApp
//
//  Created by Steffen Ryll on 09.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import MobileCoreServices
import QuickLook
import StudKit
import StudKitUI

final class CourseController: UITableViewController, Routable {
    private var viewModel: CourseViewModel!
    private var announcementsViewModel: AnnouncementListViewModel!
    private var fileListViewModel: FileListViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        registerForPreviewing(with: self, sourceView: tableView)

        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dragInteractionEnabled = true
        }

        tableView.tableHeaderView?.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView?.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        tableView.tableHeaderView?.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        tableView.tableHeaderView?.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userActivity = viewModel.course.userActivity

        announcementsViewModel.update()
        fileListViewModel.update()

        navigationItem.title = viewModel.course.title

        subtitleLabel.text = viewModel.course.subtitle

        let navigationController = splitViewController?.detailNavigationController as? BorderlessNavigationController
        navigationController?.usesDefaultAppearance = true

        tableView.tableHeaderView?.layoutIfNeeded()
        tableView.tableHeaderView = tableView.tableHeaderView
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let navigationController = splitViewController?.detailNavigationController as? BorderlessNavigationController
        navigationController?.usesDefaultAppearance = false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard self == navigationController?.topViewController else {
            return super.viewWillTransition(to: size, with: coordinator)
        }

        let controller = splitViewController?.detailNavigationController as? BorderlessNavigationController
        controller?.usesDefaultAppearance = false

        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            let controller = self.splitViewController?.detailNavigationController as? BorderlessNavigationController
            controller?.usesDefaultAppearance = true

            self.tableView.tableHeaderView?.layoutIfNeeded()
            self.tableView.tableHeaderView = self.tableView.tableHeaderView
        }, completion: nil)
    }

    // MARK: - Navigation

    func prepareContent(for route: Routes) {
        guard case let .course(course) = route else { fatalError() }

        viewModel = CourseViewModel(course: course)

        announcementsViewModel = AnnouncementListViewModel(course: course)
        announcementsViewModel.delegate = self
        announcementsViewModel.fetch()
        announcementsViewModel.update()

        fileListViewModel = FileListViewModel(container: course)
        fileListViewModel.delegate = self
        fileListViewModel.fetch()
        fileListViewModel.update()
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
        case info, announcements, documents, summary, events
    }

    private func index<Section: DataSourceSection>(for section: Section) -> Sections? {
        let section = section as AnyObject
        if section === announcementsViewModel { return Sections.announcements }
        if section === fileListViewModel { return Sections.documents }
        return nil
    }

    override func numberOfSections(in _: UITableView) -> Int {
        guard viewModel != nil else { return 0 }
        return viewModel.course.summary != nil ? 4 : 3
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .info?:
            return viewModel.numberOfRows
        case .announcements?:
            return announcementsViewModel.numberOfRows + 1
        case .documents?:
            return fileListViewModel.numberOfRows + 1
        case .events?:
            return 1
        case .summary?:
            return 1
        case nil:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .info?:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.typeIdentifier, for: indexPath)
            let titleAndValue = viewModel[rowAt: indexPath.row]
            cell.textLabel?.text = titleAndValue.title
            cell.detailTextLabel?.text = titleAndValue.value
            return cell
        case .announcements? where indexPath.row == announcementsViewModel.numberOfRows:
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath)
            cell.textLabel?.text = "No Announcements".localized
            return cell
        case .announcements?:
            let cell = tableView.dequeueReusableCell(withIdentifier: AnnouncementCell.typeIdentifier, for: indexPath)
            (cell as? AnnouncementCell)?.announcement = announcementsViewModel[rowAt: indexPath.row]
            (cell as? AnnouncementCell)?.color = viewModel.course.color
            return cell
        case .documents? where indexPath.row == fileListViewModel.numberOfRows:
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath)
            cell.textLabel?.text = "No Documents".localized
            return cell
        case .documents?:
            let cell = tableView.dequeueReusableCell(withIdentifier: FileCell.typeIdentifier, for: indexPath)
            (cell as? FileCell)?.file = fileListViewModel[rowAt: indexPath.row]
            return cell
        case .events?:
            let cell = tableView.dequeueReusableCell(withIdentifier: allEventsCellIdentifier, for: indexPath)
            cell.textLabel?.text = "All Events".localized
            return cell
        case .summary?:
            let cell = tableView.dequeueReusableCell(withIdentifier: SummaryCell.typeIdentifier, for: indexPath)
            (cell as? SummaryCell)?.textView.text = viewModel.course.summary
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
        case .info?: return nil
        case .announcements?: return "Announcements".localized
        case .documents?: return "Documents".localized
        case .events?: return "Events".localized
        case .summary?: return "Summary".localized
        case nil: fatalError()
        }
    }

    // MARK: - Table View Delegate

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
        switch Sections(rawValue: indexPath.section) {
        case .info?, .announcements?, .summary?:
            return action == #selector(copy(_:))
        case .documents?:
            let file = fileListViewModel[rowAt: indexPath.row]

            switch action {
            case #selector(CustomMenuItems.share(_:)):
                return true
            case #selector(CustomMenuItems.remove(_:)):
                return file.state.isDownloaded
            default:
                return false
            }
        case .events?, nil:
            fatalError()
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
                self.present(controller, animated: true, completion: nil)
            }
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - User Interface

    @IBOutlet var subtitleLabel: UILabel!

    // MARK: - User Interaction

    @IBAction
    func actionButtonTapped(_: Any) {
        guard let courseUrl = viewModel.course.url else { return }

        let controller = UIActivityViewController(activityItems: [courseUrl],
                                                  applicationActivities: [SafariActivity(controller: self)])
        controller.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(controller, animated: true, completion: nil)
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
            guard let data = announcementsViewModel[rowAt: indexPath.row].textContent.data(using: .utf8) else { return [] }
            return [NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)]
        case .documents? where !fileListViewModel.isEmpty:
            let file = fileListViewModel[rowAt: indexPath.row]
            guard let itemProvider = NSItemProvider(contentsOf: file.localUrl(in: .fileProvider)) else { return [] }
            itemProvider.suggestedName = file.name
            return [itemProvider]
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
