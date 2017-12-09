//
//  CourseController.swift
//  StudApp
//
//  Created by Steffen Ryll on 09.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

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

        navigationItem.title = viewModel.course.title

        subtitleLabel.text = viewModel.course.subtitle
    }

    func prepareDependencies(for route: Routes) {
        guard case let .course(course) = route else { fatalError() }

        viewModel = CourseViewModel(course: course)
        filesViewModel = FileListViewModel(course: course)
    }

    // MARK: - User Interface

    @IBOutlet weak var subtitleLabel: UILabel!

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
        default:
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
        default:
            fatalError()
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .info?: return nil
        case .documents?: return "Documents".localized
        default: fatalError()
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
