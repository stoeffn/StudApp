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

        tableView.register(FileCell.self, forCellReuseIdentifier: FileCell.typeIdentifier)

        initUserInterface()
    }

    func prepareDependencies(for route: Routes) {
        guard case let .course(course) = route else { fatalError() }

        viewModel = CourseViewModel(course: course)
        filesViewModel = FileListViewModel(course: course)
    }

    // MARK: - User Interface

    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var courseNumberCell: UITableViewCell!

    @IBOutlet weak var locationCell: UITableViewCell!

    @IBOutlet weak var summaryCell: UITableViewCell!

    @IBOutlet weak var summaryLabel: UILabel!

    private func initUserInterface() {
        subtitleLabel.text = viewModel.course.subtitle

        courseNumberCell.textLabel?.text = "Course Number".localized
        courseNumberCell.detailTextLabel?.text = viewModel.course.number

        locationCell.textLabel?.text = "Location".localized
        locationCell.detailTextLabel?.text = viewModel.course.location

        summaryLabel.text = viewModel.course.summary

        tableView.reloadData()
    }

    // MARK: - Table View Data Source

    private enum Sections: Int {
        case info, documents
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .info?:
            return viewModel.numberOfInfoFields
        case .documents?:
            return filesViewModel.numberOfRows
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .info?:
            let adjustedIndexPath = IndexPath(row: viewModel.adjustedIndexForInfoField(at: indexPath.row),
                                              section: indexPath.section)
            return super.tableView(tableView, cellForRowAt: adjustedIndexPath)
        case .documents?:
            let cell = tableView.dequeueReusableCell(withIdentifier: FileCell.typeIdentifier, for: indexPath)
            (cell as? FileCell)?.file = filesViewModel[rowAt: indexPath.row]
            return cell
        default:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        // Needs to be overridden in order to avoid index-out-of-range-exceptions caused by static cells.
        switch Sections(rawValue: indexPath.section) {
        case .documents?:
            return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: indexPath.section))
        default:
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
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
