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

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.course.title

        initUserInterface()
    }

    func prepareDependencies(for route: Routes) {
        guard case let .course(course) = route else { fatalError() }

        viewModel = CourseViewModel(course: course)
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
            return viewModel.infoFields
                .flatMap { $0 }
                .count
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .info?:
            let numberOfNonNilFields = viewModel.infoFields[0...indexPath.row]
                .flatMap { $0 }
                .count
            let offset = indexPath.row + 1 - numberOfNonNilFields
            let adjustedIndexPath = IndexPath(row: indexPath.row + offset, section: indexPath.section)
            return super.tableView(tableView, cellForRowAt: adjustedIndexPath)
        default:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
