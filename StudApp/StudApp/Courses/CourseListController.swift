//
//  CourseListController.swift
//  StudApp
//
//  Created by Steffen Ryll on 05.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit
import StudKitUI

final class CourseListController: UITableViewController, DataSourceSectionDelegate {
    private var viewModel: SemesterListViewModel!
    private var courseListViewModels: [String: CourseListViewModel] = [:]

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = SemesterListViewModel(fetchRequest: Semester.visibleStatesFetchRequest)
        viewModel.delegate = self
        viewModel.fetch()
        _ = viewModel.map(courseListViewModel)

        navigationItem.title = "Courses".localized

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }

        tableView.register(SemesterHeader.self, forHeaderFooterViewReuseIdentifier: SemesterHeader.typeIdentifier)
        tableView.tableHeaderView = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.update()
        updateEmptyView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.visibleCells.forEach { $0.setDisclosureIndicatorHidden(for: splitViewController) }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.tableView.visibleCells.forEach { $0.setDisclosureIndicatorHidden(for: self.splitViewController) }
            self.updateEmptyView()
        }, completion: nil)
    }

    // MARK: - Supporting User Activities

    override func restoreUserActivityState(_ activity: NSUserActivity) {
        guard let course = Course.fetch(byObjectId: activity.objectIdentifier) else {
            let title = "Something went wrong continuing your activity.".localized
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
            return present(alert, animated: true, completion: nil)
        }

        performSegue(withRoute: .course(course))
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in _: UITableView) -> Int {
        return viewModel.numberOfRows
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        let semester = viewModel[rowAt: section]
        return courseListViewModel(for: semester).numberOfRows
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return SemesterHeader.height
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SemesterHeader.typeIdentifier)
        let semester = viewModel[rowAt: section]
        (header as? SemesterHeader)?.semester = semester
        (header as? SemesterHeader)?.courseListViewModel = courseListViewModel(for: semester)
        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CourseCell.typeIdentifier, for: indexPath)
        let semester = viewModel[rowAt: indexPath.section]
        let course = courseListViewModel(for: semester)[rowAt: indexPath.row]
        cell.setDisclosureIndicatorHidden(for: splitViewController)
        (cell as? CourseCell)?.course = course
        (cell as? CourseCell)?.presentColorPicker = presentColorPicker
        return cell
    }

    // MARK: - Table View Delegate

    override func tableView(_: UITableView, shouldShowMenuForRowAt _: IndexPath) -> Bool {
        return true
    }

    override func tableView(_: UITableView, canPerformAction action: Selector, forRowAt _: IndexPath,
                            withSender _: Any?) -> Bool {
        return action == #selector(CustomMenuItems.color(_:))
    }

    /// Empty implementation that is needed in order for the menu to appear.
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
        switch section {
        case is SemesterListViewModel:
            data(changedInSemester: row as? Semester, at: index, change: change as? DataChange<Semester, Int> ?? .delete)
        case is CourseListViewModel:
            data(changedInCourse: row as? Course, at: index, change: change as? DataChange<Course, Int> ?? .delete, in: section)
        default:
            return
        }
    }

    func data(changedInSemester _: Semester?, at index: Int, change: DataChange<Semester, Int>) {
        switch change {
        case .insert:
            tableView.insertSections(IndexSet(integer: index), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: index), with: .automatic)
        case .update:
            break
        case let .move(newIndex):
            tableView.moveSection(index, toSection: newIndex)
        }
    }

    func data<Section: DataSourceSection>(changedInCourse course: Course?, at index: Int, change: DataChange<Course, Int>,
                                          in section: Section) {
        guard
            let courseListViewModel = section as? CourseListViewModel,
            let sectionIndex = self.index(for: courseListViewModel)
        else { return }

        let indexPath = IndexPath(row: index, section: sectionIndex)

        switch change {
        case .insert:
            tableView.insertRows(at: [indexPath], with: .middle)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .middle)
        case .update:
            let cell = tableView.cellForRow(at: indexPath) as? CourseCell
            cell?.course = course
        case let .move(newIndex):
            let cell = tableView.cellForRow(at: indexPath) as? CourseCell
            let newIndexPath = IndexPath(row: newIndex, section: sectionIndex)
            tableView.moveRow(at: indexPath, to: newIndexPath)
            cell?.course = course
        }
    }

    func dataDidChange<Section: DataSourceSection>(in _: Section) {
        pruneCourseListViewModels()
        tableView.endUpdates()
    }

    // MARK: - Managing Course List View Models

    private func courseListViewModel(for semester: Semester) -> CourseListViewModel {
        if let viewModel = courseListViewModels[semester.id] { return viewModel }

        let viewModel = CourseListViewModel(semester: semester, respectsCollapsedState: true)
        viewModel.delegate = self
        viewModel.fetch()
        viewModel.update()

        courseListViewModels[semester.id] = viewModel

        return viewModel
    }

    private func index(for courseListViewModel: CourseListViewModel) -> Int? {
        for index in 0 ..< tableView.numberOfSections {
            guard
                let header = tableView.headerView(forSection: index) as? SemesterHeader,
                header.courseListViewModel === courseListViewModel
            else { continue }
            return index
        }
        return nil
    }

    private func pruneCourseListViewModels() {
        let existingSemesterIds = Set(viewModel.map { $0.id })
        courseListViewModels
            .map { $0.key }
            .filter { !existingSemesterIds.contains($0) }
            .forEach { courseListViewModels.removeValue(forKey: $0) }
    }

    // MARK: - User Interface

    @IBOutlet var emptyView: UIView!

    @IBOutlet var emptyViewTopConstraint: NSLayoutConstraint!

    @IBOutlet var emptyViewTitleLabel: UILabel!

    @IBOutlet var emptyViewSubtitleLabel: UILabel!

    @IBOutlet var emptyViewActionButton: UIButton!

    private func updateEmptyView() {
        guard view != nil else { return }

        emptyViewTitleLabel.text = "It Looks Like There Are No Semesters".localized
        emptyViewSubtitleLabel.text = "You can try to reload the semesters from Stud.IP.".localized
        emptyViewActionButton.setTitle("Reload".localized, for: .normal)

        tableView.backgroundView = viewModel.isEmpty ? emptyView : nil
        tableView.separatorStyle = viewModel.isEmpty ? .none : .singleLine
        tableView.bounces = !viewModel.isEmpty

        if let navigationBarHeight = navigationController?.navigationBar.bounds.height {
            emptyViewTopConstraint.constant = navigationBarHeight * 2 + 32
        }
    }

    private func presentColorPicker(for cell: CourseCell) {
        let route = Routes.colorPicker(sender: cell) { id, _ in
            cell.course.groupId = id
            UISelectionFeedbackGenerator().selectionChanged()
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
        performSegue(withRoute: route)
    }

    @available(iOS 11.0, *)
    private func colorAction(for cell: CourseCell, at _: IndexPath) -> UIContextualAction {
        func colorActionHandler(_: UIContextualAction, _: UIView, success: @escaping (Bool) -> Void) {
            presentColorPicker(for: cell)
            success(true)
        }

        let action = UIContextualAction(style: .normal, title: "Color".localized, handler: colorActionHandler)
        action.backgroundColor = cell.colorView.backgroundColor
        action.image = #imageLiteral(resourceName: "ColorActionGlyph")
        return action
    }

    // MARK: - User Interaction

    @IBAction
    func userButtonTapped(_ sender: Any) {
        (tabBarController as? AppController)?.userButtonTapped(sender)
    }

    @IBAction
    func emptyViewActionButtonTapped(_: Any) {
        viewModel?.update()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? CourseCell {
            return prepare(for: .course(cell.course), destination: segue.destination)
        }
        if case let .colorPicker(sender, _)? = sender as? Routes {
            let cell = sender as? UITableViewCell
            segue.destination.popoverPresentationController?.delegate = self
            segue.destination.popoverPresentationController?.sourceView = cell
            segue.destination.popoverPresentationController?.sourceRect = cell?.bounds ?? .zero
        }
        prepareForRoute(using: segue, sender: sender)
    }
}

// MARK: - Popover Presentation

extension CourseListController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
