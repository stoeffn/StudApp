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

        courseListViewModels = viewModel.map(courseListViewModel)

        splitViewController?.preferredDisplayMode = .allVisible

        navigationItem.title = "Courses".localized

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }

        tableView.register(SemesterHeader.self, forHeaderFooterViewReuseIdentifier: SemesterHeader.typeIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.update()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.tableView.visibleCells.forEach { $0.setDisclosureIndicatorHidden(for: self.splitViewController) }
        }, completion: nil)
    }

    // MARK: - Supporting User Activities

    override func restoreUserActivityState(_ activity: NSUserActivity) {
        guard
            activity.activityType == UserActivities.courseIdentifier,
            let courseId = activity.userInfo?[Course.typeIdentifier] as? String,
            let courseViewModel = CourseViewModel(courseId: courseId)
        else {
            let alert = UIAlertController(title: "Something went wrong continuing your activity.".localized)
            return present(alert, animated: true, completion: nil)
        }

        performSegue(withRoute: .course(courseViewModel.course))
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
        cell.setDisclosureIndicatorHidden(for: splitViewController)
        (cell as? CourseCell)?.controller = self
        (cell as? CourseCell)?.course = courseListViewModels[indexPath.section][rowAt: indexPath.row]
        return cell
    }

    private func courseListViewModel(for semester: Semester) -> CourseListViewModel {
        let viewModel = CourseListViewModel(semester: semester, respectsCollapsedState: true)
        viewModel.delegate = self
        viewModel.fetch()
        viewModel.update()
        return viewModel
    }

    // MARK: - Table View Delegate

    override func tableView(_: UITableView, shouldShowMenuForRowAt _: IndexPath) -> Bool {
        return true
    }

    override func tableView(_: UITableView, canPerformAction action: Selector, forRowAt _: IndexPath,
                            withSender _: Any?) -> Bool {
        return action == #selector(CustomMenuItems.color(_:))
    }

    override func tableView(_: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender _: Any?) {
        return
    }

    @available(iOS 11.0, *)
    override func tableView(_: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? CourseCell else { return nil }

        return UISwipeActionsConfiguration(actions: [
            colorAction(for: cell, at: indexPath),
        ])
    }

    @available(iOS 11.0, *)
    override func tableView(_: UITableView,
                            trailingSwipeActionsConfigurationForRowAt _: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [])
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

    func data<Section: DataSourceSection>(changedInCourse course: Course, at index: Int, change: DataChange<Course, Int>,
                                          in section: Section) {
        guard let courseListViewModel = section as? CourseListViewModel,
            let sectionIndex = courseListViewModels.index(of: courseListViewModel) else { return }
        let indexPath = IndexPath(row: index, section: sectionIndex)
        let cell = tableView.cellForRow(at: indexPath) as? CourseCell

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
            cell?.course = course
        }
    }

    // MARK: - User Interface

    @available(iOS 11.0, *)
    private func colorAction(for cell: CourseCell, at _: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Color".localized) { _, _, success in
            cell.color(nil)
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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch sender {
        case let cell as CourseCell:
            prepare(for: .course(cell.course), destination: segue.destination)
        default:
            prepareForRoute(using: segue, sender: sender)
        }
    }
}
