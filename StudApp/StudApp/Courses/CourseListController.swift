//
//  CourseListController.swift
//  StudApp
//
//  Created by Steffen Ryll on 05.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class CourseListController: UITableViewController, DataSourceSectionDelegate {
    private var viewModel: SemesterListViewModel!
    private var courseViewModels: [CourseListViewModel]!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = SemesterListViewModel(fetchRequest: Semester.nonHiddenFetchRequest)
        viewModel.delegate = self
        viewModel.fetch()
        viewModel.update()

        updateCourseViewModels()

        navigationItem.title = "Courses".localized

        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.register(SemesterHeader.self, forHeaderFooterViewReuseIdentifier: SemesterHeader.typeIdentifier)
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in _: UITableView) -> Int {
        return viewModel.numberOfRows
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseViewModels[section].numberOfRows
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return SemesterHeader.height
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SemesterHeader.typeIdentifier)
        (header as? SemesterHeader)?.semester = viewModel[rowAt: section]
        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CourseCell.typeIdentifier, for: indexPath)
        (cell as? CourseCell)?.course = courseViewModels[indexPath.section][rowAt: indexPath.row]
        return cell
    }

    private func updateCourseViewModels() {
        courseViewModels = viewModel.map { CourseListViewModel(fetchRequest: $0.coursesFetchRequest) }
        courseViewModels.forEach { $0.fetch() }
    }

    // MARK: - Responding to Changed Data

    func dataDidChange<Section: DataSourceSection>(in _: Section) {
        updateCourseViewModels()
        tableView.endUpdates()
    }
}
