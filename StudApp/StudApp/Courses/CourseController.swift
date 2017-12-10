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
    private var viewModel: CourseViewModel!
    private var filesViewModel: FileListViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        filesViewModel.delegate = self
        filesViewModel.fetch()
        filesViewModel.update()

        registerForPreviewing(with: self, sourceView: tableView)

        navigationItem.title = viewModel.course.title

        subtitleLabel.text = viewModel.course.subtitle

        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dragInteractionEnabled = true
        }
    }

    func prepareDependencies(for route: Routes) {
        guard case let .course(course) = route else { fatalError() }

        viewModel = CourseViewModel(course: course)
        filesViewModel = FileListViewModel(course: course)
    }

    // MARK: - Table View Data Source

    private enum Sections: Int {
        case info, documents
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .info?:
            return viewModel.numberOfRows
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
        case .documents?: return "Documents".localized
        case nil: fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .info?: return viewModel.course.summary
        case .documents?: return nil
        case nil: fatalError()
        }
    }

    // MARK: - Table View Delegate

    override func tableView(_: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        switch Sections(rawValue: indexPath.section) {
        case .info?, .documents?:
            return true
        case nil:
            fatalError()
        }
    }

    override func tableView(_: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath,
                            withSender _: Any?) -> Bool {
        switch Sections(rawValue: indexPath.section) {
        case .info?:
            return action == #selector(copy(_:))
        case .documents?:
            let file = filesViewModel[rowAt: indexPath.row]

            switch action {
            case #selector(copy(_:)), #selector(CustomMenuItems.share(_:)):
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
            switch action {
            case #selector(copy(_:)):
                let titleAndValue = viewModel[rowAt: indexPath.row]
                UIPasteboard.general.string = titleAndValue.value
            default:
                break
            }
        case .documents?:
            let file = filesViewModel[rowAt: indexPath.row]

            switch action {
            case #selector(copy(_:)):
                let documentUrl = file.localUrl(inProviderDirectory: true)
                guard let data = try? Data(contentsOf: documentUrl, options: .mappedIfSafe) else { return }
                UIPasteboard.general.setData(data, forPasteboardType: file.typeIdentifier)
            default:
                break
            }
        case nil:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Sections(rawValue: indexPath.section) {
        case .info?:
            break
        case .documents?:
            guard
                let cell = tableView.cellForRow(at: indexPath) as? FileCell,
                !cell.file.isFolder
            else { return }

            preview(cell.file)
            tableView.deselectRow(at: indexPath, animated: true)
        case nil:
            fatalError()
        }
    }

    // MARK: - User Interface

    @IBOutlet weak var subtitleLabel: UILabel!

    private func preview(_ file: File) {
        file.download { result in
            guard result.isSuccess else {
                let alert = UIAlertController(title: result.error?.localizedDescription, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }

            let previewController = PreviewController()
            previewController.prepareDependencies(for: .preview(file))
            self.present(previewController, animated: true, completion: nil)
        }
    }

    // MARK: - User Interaction

    @IBAction
    func actionButtonTapped(_: Any) {
        guard let courseUrl = viewModel.course.url else { return }

        let controller = UIActivityViewController(activityItems: [courseUrl], applicationActivities: [SafariActivity()])
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
    private func items(forIndexPath indexPath: IndexPath) -> [UIDragItem] {
        switch Sections(rawValue: indexPath.section) {
        case .info?:
            let titleAndValue = viewModel[rowAt: indexPath.row]
            let itemProvider = NSItemProvider(item: titleAndValue.value as NSSecureCoding?,
                                              typeIdentifier: kUTTypePlainText as String)
            return [UIDragItem(itemProvider: itemProvider)]
        case .documents?:
            let file = filesViewModel[rowAt: indexPath.row]
            guard let itemProvider = NSItemProvider(contentsOf: file.localUrl(inProviderDirectory: true)) else { return [] }
            return [UIDragItem(itemProvider: itemProvider)]
        case nil:
            fatalError()
        }
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

extension CourseController: UIViewControllerPreviewingDelegate {
    func previewingContext(_: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

        switch Sections(rawValue: indexPath.section) {
        case .info?:
            return nil
        case .documents?:
            let file = filesViewModel[rowAt: indexPath.row]
            guard !file.isFolder else { return nil }
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
