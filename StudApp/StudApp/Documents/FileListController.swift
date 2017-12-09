//
//  CourseController.swift
//  StudApp
//
//  Created by Steffen Ryll on 09.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class FileListController: UITableViewController, DataSourceSectionDelegate, Routable {
    private var viewModel: FileListViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        viewModel.fetch()
        viewModel.update()

        registerForPreviewing(with: self, sourceView: tableView)

        navigationItem.title = viewModel.title

        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dragInteractionEnabled = true
        }
    }

    func prepareDependencies(for route: Routes) {
        guard case let .folder(folder) = route else { fatalError() }

        viewModel = FileListViewModel(folder: folder)
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

    override func tableView(_: UITableView, shouldShowMenuForRowAt _: IndexPath) -> Bool {
        return true
    }

    override func tableView(_: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath,
                            withSender _: Any?) -> Bool {
        let file = viewModel[rowAt: indexPath.row]

        switch action {
        case #selector(copy(_:)), #selector(CustomMenuItems.share(_:)):
            return true
        case #selector(CustomMenuItems.remove(_:)):
            return file.state.isDownloaded
        default:
            return false
        }
    }

    override func tableView(_: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender _: Any?) {
        let file = viewModel[rowAt: indexPath.row]

        switch action {
        case #selector(copy(_:)):
            let documentUrl = file.documentUrl(inProviderDirectory: true)
            guard let data = try? Data(contentsOf: documentUrl, options: .mappedIfSafe) else { return }
            UIPasteboard.general.setData(data, forPasteboardType: file.typeIdentifier)
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let cell = tableView.cellForRow(at: indexPath) as? FileCell,
            !cell.file.isFolder
        else { return }

        preview(cell.file)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - User Interface

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
        guard let url = viewModel.folder?.documentUrl else { return }

        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
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

// MARK: - Table View Drag Delegate

@available(iOS 11.0, *)
extension FileListController: UITableViewDragDelegate {
    private func items(forIndexPath indexPath: IndexPath) -> [UIDragItem] {
        let file = viewModel[rowAt: indexPath.row]
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

extension FileListController: UIViewControllerPreviewingDelegate {
    func previewingContext(_: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        let file = viewModel[rowAt: indexPath.row]
        guard !file.isFolder else { return nil }
        let previewController = PreviewController()
        previewController.prepareDependencies(for: .preview(file))
        return previewController
    }

    func previewingContext(_: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit, animated: true, completion: nil)
    }
}
