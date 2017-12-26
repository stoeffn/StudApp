//
//  CourseController.swift
//  StudApp
//
//  Created by Steffen Ryll on 09.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import MobileCoreServices
import StudKit
import QuickLook

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userActivity = viewModel.course.userActivity

        announcementsViewModel.update()
        fileListViewModel.update()

        navigationItem.title = viewModel.course.title
        navigationItem.prompt = viewModel.course.subtitle

        (splitViewController?.detailNavigationController as? BorderlessNavigationController)?.usesDefaultAppearance = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        (splitViewController?.detailNavigationController as? BorderlessNavigationController)?.usesDefaultAppearance = false
    }

    private func configureViewModels(with course: Course) {
        viewModel = CourseViewModel(course: course)

        announcementsViewModel = AnnouncementListViewModel(course: course)
        announcementsViewModel.delegate = self
        announcementsViewModel.fetch()

        fileListViewModel = FileListViewModel(course: course)
        fileListViewModel.delegate = self
        fileListViewModel.fetch()
    }

    func prepareDependencies(for route: Routes) {
        guard case let .course(course) = route else { fatalError() }
        configureViewModels(with: course)
    }

    // MARK: - Restoration

    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(viewModel.course.objectIdentifier.rawValue, forKey: ObjectIdentifier.typeIdentifier)
        super.encode(with: coder)
    }

    override func decodeRestorableState(with coder: NSCoder) {
        if
            let restoredObjectIdentifier = coder.decodeObject(forKey: ObjectIdentifier.typeIdentifier) as? String,
            let course = Course.fetch(byObjectId: ObjectIdentifier(rawValue: restoredObjectIdentifier)) {
            configureViewModels(with: course)
        }

        super.decodeRestorableState(with: coder)
    }

    // MARK: - Supporting User Activities

    override func updateUserActivityState(_ activity: NSUserActivity) {
        activity.objectIdentifier = viewModel.course.objectIdentifier
    }

    // MARK: - Table View Data Source

    private let emptyCellIdentifier = "EmptyCell"

    private enum Sections: Int {
        case info, announcements, documents
    }

    private func index<Section: DataSourceSection>(for section: Section) -> Sections? {
        let section = section as AnyObject
        if section === announcementsViewModel { return Sections.announcements }
        if section === fileListViewModel { return Sections.documents }
        return nil
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 3
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .info?:
            return viewModel.numberOfRows
        case .announcements?:
            return announcementsViewModel.numberOfRows + 1
        case .documents?:
            return fileListViewModel.numberOfRows + 1
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
            (cell as? AnnouncementCell)?.color = viewModel.course.state.color
            return cell
        case .documents? where indexPath.row == fileListViewModel.numberOfRows:
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath)
            cell.textLabel?.text = "No Documents".localized
            return cell
        case .documents?:
            let cell = tableView.dequeueReusableCell(withIdentifier: FileCell.typeIdentifier, for: indexPath)
            (cell as? FileCell)?.file = fileListViewModel[rowAt: indexPath.row]
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
        case nil: fatalError()
        }
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .info?: return viewModel.course.summary
        case .announcements?, .documents?: return nil
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
        case .info?, .announcements?:
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
        case nil:
            fatalError()
        }
    }

    override func tableView(_: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender _: Any?) {
        switch Sections(rawValue: indexPath.section) {
        case .info?:
            if action == #selector(copy(_:)) {
                let titleAndValue = viewModel[rowAt: indexPath.row]
                UIPasteboard.general.string = titleAndValue.value
            }
        case .announcements?:
            UIPasteboard.general.string = announcementsViewModel[rowAt: indexPath.row].body
        case .documents?:
            break
        case nil:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Sections(rawValue: indexPath.section) {
        case .announcements? where !announcementsViewModel.isEmpty:
            break
        case .documents? where !announcementsViewModel.isEmpty:
            guard let cell = tableView.cellForRow(at: indexPath) as? FileCell, !cell.file.isFolder else { return }
            downloadOrPreview(cell.file)
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - User Interface

    private func downloadOrPreview(_ file: File) {
        guard file.state.isMostRecentVersionDownloaded else {
            file.download { result in
                guard result.isFailure else { return }

                let alert = UIAlertController(title: result.error?.localizedDescription)
                self.present(alert, animated: true, completion: nil)
            }
            return
        }

        let previewController = PreviewController()
        previewController.prepareDependencies(for: .preview(file, self))
        present(previewController, animated: true, completion: nil)
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

    // MARK: - Navigation

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
        case let cell as AnnouncementCell:
            prepare(for: .announcement(cell.announcement), destination: segue.destination)
        case let cell as FileCell:
            prepare(for: .folder(cell.file), destination: segue.destination)
        default:
            prepareForRoute(using: segue, sender: sender)
        }
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
            tableView.insertRows(at: [indexPath], with: .middle)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .middle)
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
            guard let data = announcementsViewModel[rowAt: indexPath.row].body.data(using: .utf8) else { return [] }
            return [NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)]
        case .documents? where !fileListViewModel.isEmpty:
            let file = fileListViewModel[rowAt: indexPath.row]
            guard let itemProvider = NSItemProvider(contentsOf: file.localUrl(in: .fileProvider)) else { return [] }
            itemProvider.suggestedName = file.sanitizedTitleWithExtension
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
            previewController.prepareDependencies(for: .preview(file, self))
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
