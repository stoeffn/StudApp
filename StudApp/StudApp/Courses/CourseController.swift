//
//  CourseController.swift
//  StudApp
//
//  Created by Steffen Ryll on 09.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import MobileCoreServices
import StudKit

final class CourseController: UITableViewController, Routable {
    private var restoredCourseId: String?
    private var viewModel: CourseViewModel!
    private var announcementsViewModel: AnnouncementListViewModel!
    private var filesViewModel: FileListViewModel!

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

        userActivity = userActivity()

        announcementsViewModel.update()
        filesViewModel.update()

        navigationItem.title = viewModel.course.title
        subtitleLabel.text = viewModel.course.subtitle
    }

    private func configureViewModels(with course: Course) {
        announcementsViewModel = AnnouncementListViewModel(course: course)
        announcementsViewModel.delegate = self
        announcementsViewModel.fetch()

        filesViewModel = FileListViewModel(course: course)
        filesViewModel.delegate = self
        filesViewModel.fetch()
    }

    func prepareDependencies(for route: Routes) {
        guard case let .course(course) = route else { fatalError() }

        viewModel = CourseViewModel(course: course)
        configureViewModels(with: course)
    }

    // MARK: - Restoration

    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(viewModel.course.id, forKey: Course.typeIdentifier)
        super.encode(with: coder)
    }

    override func decodeRestorableState(with coder: NSCoder) {
        restoredCourseId = coder.decodeObject(forKey: Course.typeIdentifier) as? String
        super.decodeRestorableState(with: coder)
    }

    override func applicationFinishedRestoringState() {
        guard let courseId = restoredCourseId else { return }

        viewModel = CourseViewModel(courseId: courseId)
        configureViewModels(with: viewModel.course)
    }

    // MARK: - Supporting User Activities

    func userActivity() -> NSUserActivity {
        let activity = NSUserActivity(activityType: UserActivities.courseIdentifier)
        activity.isEligibleForHandoff = true
        activity.title = viewModel.course.title
        activity.webpageURL = viewModel.course.url
        activity.requiredUserInfoKeys = [Course.typeIdentifier]
        return activity
    }

    override func updateUserActivityState(_ activity: NSUserActivity) {
        activity.addUserInfoEntries(from: [Course.typeIdentifier: viewModel.course.id])
    }

    // MARK: - Table View Data Source

    private enum Sections: Int {
        case info, announcements, documents
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 3
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .info?:
            return viewModel.numberOfRows
        case .announcements?:
            return announcementsViewModel.numberOfRows
        case .documents?:
            return filesViewModel.numberOfRows
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
        case .announcements?:
            let cell = tableView.dequeueReusableCell(withIdentifier: AnnouncementCell.typeIdentifier, for: indexPath)
            (cell as? AnnouncementCell)?.announcement = announcementsViewModel[rowAt: indexPath.row]
            return cell
        case .documents?:
            let cell = tableView.dequeueReusableCell(withIdentifier: FileCell.typeIdentifier, for: indexPath)
            (cell as? FileCell)?.file = filesViewModel[rowAt: indexPath.row]
            return cell
        case nil:
            fatalError()
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
        case .info?, .announcements?, .documents?:
            return true
        case nil:
            fatalError()
        }
    }

    override func tableView(_: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath,
                            withSender _: Any?) -> Bool {
        switch Sections(rawValue: indexPath.section) {
        case .info?, .announcements?:
            return action == #selector(copy(_:))
        case .documents?:
            let file = filesViewModel[rowAt: indexPath.row]

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
        case .info?, .announcements?:
            break
        case .documents?:
            guard
                let cell = tableView.cellForRow(at: indexPath) as? FileCell,
                !cell.file.isFolder
            else { return }

            downloadOrPreview(cell.file)
            tableView.deselectRow(at: indexPath, animated: true)
        case nil:
            fatalError()
        }
    }

    // MARK: - User Interface

    @IBOutlet weak var subtitleLabel: UILabel!

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
        previewController.prepareDependencies(for: .preview(file))
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
    public func data<Section: DataSourceSection>(changedIn _: Section.Row, at index: Int, change: DataChange<Section.Row, Int>,
                                                 in _: Section) {
        let indexPath = IndexPath(row: index, section: Sections.documents.rawValue)
        switch change {
        case .insert:
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case let .move(newIndex):
            let newIndexPath = IndexPath(row: newIndex, section: Sections.documents.rawValue)
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
            guard let value = viewModel[rowAt: indexPath.row].value else { return [] }
            return [NSItemProvider(item: value as NSString, typeIdentifier: kUTTypePlainText as String)]
        case .announcements?:
            let value = announcementsViewModel[rowAt: indexPath.row].body
            return [NSItemProvider(item: value as NSString, typeIdentifier: kUTTypePlainText as String)]
        case .documents?:
            let file = filesViewModel[rowAt: indexPath.row]
            guard let itemProvider = NSItemProvider(contentsOf: file.localUrl(inProviderDirectory: true)) else { return [] }
            itemProvider.suggestedName = file.sanitizedTitleWithExtension
            return [itemProvider]
        case nil:
            fatalError()
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

extension CourseController: UIViewControllerPreviewingDelegate {
    func previewingContext(_: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

        switch Sections(rawValue: indexPath.section) {
        case .info?, .announcements?:
            return nil
        case .documents?:
            let file = filesViewModel[rowAt: indexPath.row]
            guard !file.isFolder && file.state.isDownloaded else { return nil }

            let previewController = PreviewController()
            previewController.prepareDependencies(for: .preview(file))
            return previewController
        case nil:
            fatalError()
        }
    }

    func previewingContext(_: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit, animated: true, completion: nil)
    }
}
