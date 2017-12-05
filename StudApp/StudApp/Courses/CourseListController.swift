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
        courseViewModels = viewModel.map { CourseListViewModel(semester: $0) }
        courseViewModels.forEach { $0.fetch() }
    }

    // MARK: - Responding to Changed Data

    func dataDidChange<Section: DataSourceSection>(in _: Section) {
        updateCourseViewModels()
        tableView.endUpdates()
    }

    func data<Section: DataSourceSection>(changedIn row: Section.Row, at index: Int, change: DataChange<Section.Row, Int>,
                                          in section: Section) {
        if let semester = row as? Semester, let change = change as? DataChange<Semester, Int> {
            data(changedInSemester: semester, at: index, change: change)
        } else if let course = row as? Course, let change = change as? DataChange<Course, Int> {
            data(changedInCourse: course, at: index, change: change, in: section)
        }
    }

    func data(changedInSemester _: Semester, at index: Int, change: DataChange<Semester, Int>) {
        switch change {
        case .insert:
            tableView.insertSections(IndexSet(integer: index), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: index), with: .automatic)
        case .update:
            tableView.reloadSections(IndexSet(integer: index), with: .automatic)
        case let .move(newIndex):
            tableView.moveSection(index, toSection: newIndex)
        }
    }

    func data<Section: DataSourceSection>(changedInCourse _: Course, at index: Int, change: DataChange<Course, Int>,
                                          in section: Section) {
        guard let courseListViewModel = section as? CourseListViewModel,
            let sectionIndex = courseViewModels.index(of: courseListViewModel) else { return }
        let indexPath = IndexPath(row: index, section: sectionIndex)

        switch change {
        case .insert:
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case let .move(newIndex):
            let newIndexPath = IndexPath(row: newIndex, section: sectionIndex)
            tableView.moveRow(at: indexPath, to: newIndexPath)
        }
    }
}
