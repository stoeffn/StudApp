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

        navigationItem.title = viewModel.title
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
