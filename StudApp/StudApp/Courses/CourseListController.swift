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
    private var courseListViewModels: [CourseListViewModel]!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = SemesterListViewModel(fetchRequest: Semester.nonHiddenFetchRequest)
        viewModel.delegate = self
        viewModel.fetch()
        viewModel.update()

        courseListViewModels = viewModel.map(courseListViewModel)

        navigationItem.title = "Courses".localized

        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.register(SemesterHeader.self, forHeaderFooterViewReuseIdentifier: SemesterHeader.typeIdentifier)
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in _: UITableView) -> Int {
        return viewModel.numberOfRows
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseListViewModels[section].numberOfRows
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return SemesterHeader.height
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SemesterHeader.typeIdentifier)
        (header as? SemesterHeader)?.semester = viewModel[rowAt: section]
        (header as? SemesterHeader)?.courseListViewModel = courseListViewModels[section]
        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CourseCell.typeIdentifier, for: indexPath)
        (cell as? CourseCell)?.course = courseListViewModels[indexPath.section][rowAt: indexPath.row]
        return cell
    }

    private func courseListViewModel(for semester: Semester) -> CourseListViewModel {
        let viewModel = CourseListViewModel(semester: semester, respectsCollapsedState: true)
        viewModel.delegate = self
        viewModel.fetch()
        return viewModel
    }

    // MARK: - Table View Delegate

    override func tableView(_: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? CourseCell else { return nil }

        return UISwipeActionsConfiguration(actions: [
            colorAction(for: cell, at: indexPath),
        ])
    }

    // MARK: - Responding to Changed Data

    func data<Section: DataSourceSection>(changedIn row: Section.Row, at index: Int, change: DataChange<Section.Row, Int>,
                                          in section: Section) {
        if let semester = row as? Semester, let change = change as? DataChange<Semester, Int> {
            data(changedInSemester: semester, at: index, change: change)
        } else if let course = row as? Course, let change = change as? DataChange<Course, Int> {
            data(changedInCourse: course, at: index, change: change, in: section)
        }
    }

    func data(changedInSemester semester: Semester, at index: Int, change: DataChange<Semester, Int>) {
        switch change {
        case .insert:
            courseListViewModels.insert(courseListViewModel(for: semester), at: index)
            tableView.insertSections(IndexSet(integer: index), with: .automatic)
        case .delete:
            courseListViewModels.remove(at: index)
            tableView.deleteSections(IndexSet(integer: index), with: .fade)
        case .update:
            break
        case let .move(newIndex):
            let courseListViewModel = courseListViewModels.remove(at: index)
            courseListViewModels.insert(courseListViewModel, at: newIndex)
            tableView.moveSection(index, toSection: newIndex)
        }
    }

    func data<Section: DataSourceSection>(changedInCourse _: Course, at index: Int, change: DataChange<Course, Int>,
                                          in section: Section) {
        guard let courseListViewModel = section as? CourseListViewModel,
            let sectionIndex = courseListViewModels.index(of: courseListViewModel) else { return }
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

    // MARK: - User Interface

    private func colorAction(for cell: CourseCell, at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Color") { _, _, success in
            self.colorActionActivated(withCourse: cell.course, at: indexPath)
            success(true)
        }
        action.backgroundColor = cell.colorView.backgroundColor
        action.image = #imageLiteral(resourceName: "ColorActionGlyph")
        return action
    }

    // MARK: - User Interaction

    @IBAction
    func userButtonTapped(_ sender: Any) {
        (tabBarController as? MainController)?.userButtonTapped(sender)
    }

    private func colorActionActivated(withCourse course: Course, at indexPath: IndexPath) {
        let course = courseListViewModels[indexPath.section][rowAt: indexPath.row]
        let route = Routes.colorPicker { id, _ in
            course.state.colorId = id
        }
        performSegue(withRoute: route)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        prepareForRoute(using: segue, sender: sender)
    }
}
