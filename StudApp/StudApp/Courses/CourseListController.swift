//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

import StudKit
import StudKitUI

final class CourseListController: UITableViewController, DataSourceSectionDelegate, Routable {
    private var user: User?
    private var viewModel: SemesterListViewModel?
    private var courseListViewModels: [String: CourseListViewModel] = [:]
    private var observations = [NSKeyValueObservation]()

    // MARK: - Life Cycle

    deinit {
        observations.removeAll()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Courses".localized
        navigationItem.rightBarButtonItem?.accessibilityLabel = "More".localized

        refreshControl?.addTarget(self, action: #selector(refreshControlTriggered(_:)), for: .valueChanged)

        tableView.register(SemesterHeader.self, forHeaderFooterViewReuseIdentifier: SemesterHeader.typeIdentifier)
        tableView.tableHeaderView = nil
        tableView.estimatedSectionHeaderHeight = SemesterHeader.estimatedHeight

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true

            tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        }

        updateEmptyView()

        observations = [
            UserDefaults.studKit.observe(\.showsHiddenCourses, options: [.old, .new]) { [weak self] _, change in
                guard let `self` = self, change.newValue != change.oldValue else { return }
                self.prepareContent(for: .courseList(for: User.current))
            },
        ]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.visibleCells.forEach { $0.setDisclosureIndicatorHidden(for: splitViewController) }
        updateEmptyView()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.tableView.visibleCells.forEach { $0.setDisclosureIndicatorHidden(for: self.splitViewController) }
            self.updateEmptyView()
        }, completion: nil)
    }

    // MARK: - Navigation

    func prepareContent(for route: Routes) {
        guard case let .courseList(for: optionalUser) = route else { fatalError() }
        self.user = optionalUser

        defer {
            tableView.reloadData()
            updateEmptyView()
        }

        courseListViewModels = [:]

        guard let user = optionalUser else { return viewModel = nil }

        viewModel = SemesterListViewModel(organization: user.organization)
        viewModel?.delegate = self
        viewModel?.fetch()
        _ = viewModel?.enumerated().map { courseListViewModel(for: $1, at: $0) }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let user = user else { fatalError() }

        if let cell = sender as? CourseCell {
            return prepare(for: .course(cell.course), destination: segue.destination)
        } else if segue.identifier == Routes.semesterList(for: user).segueIdentifier {
            return prepare(for: .semesterList(for: user), destination: segue.destination)
        }

        if case let .colorPicker(sender, _)? = sender as? Routes {
            let cell = sender as? UITableViewCell
            segue.destination.popoverPresentationController?.delegate = self
            segue.destination.popoverPresentationController?.sourceView = cell
            segue.destination.popoverPresentationController?.sourceRect = cell?.bounds ?? .zero
        }

        prepareForRoute(using: segue, sender: sender)
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
        return viewModel?.numberOfRows ?? 0
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let semester = viewModel?[rowAt: section] else { fatalError() }
        return courseListViewModel(for: semester, at: section).numberOfRows
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SemesterHeader.typeIdentifier)
        guard let semester = viewModel?[rowAt: section] else { fatalError() }
        (header as? SemesterHeader)?.semester = semester
        (header as? SemesterHeader)?.courseListViewModel = courseListViewModel(for: semester, at: section)
        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CourseCell.typeIdentifier, for: indexPath)
        guard let semester = viewModel?[rowAt: indexPath.section] else { fatalError() }
        let course = courseListViewModel(for: semester, at: indexPath.section)[rowAt: indexPath.row]
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
        switch action {
        case #selector(CustomMenuItems.color(_:)):
            return user?.organization.supportsSettingCourseGroups ?? false
        case #selector(CustomMenuItems.hide(_:)):
            return true
        default:
            return false
        }
    }

    /// Empty implementation that is needed in order for the menu to appear.
    override func tableView(_: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender _: Any?) {}

    @available(iOS 11.0, *)
    override func tableView(_: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath) as? CourseCell
        return UISwipeActionsConfiguration(actions: [
            colorAction(for: cell),
        ].compactMap { $0 })
    }

    @available(iOS 11.0, *)
    override func tableView(_: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath) as? CourseCell
        return UISwipeActionsConfiguration(actions: [
            hideAction(for: cell),
        ].compactMap { $0 })
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
            fatalError()
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
        else { fatalError() }

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
        updateEmptyView()
    }

    // MARK: - Managing Course List View Models

    private func courseListViewModel(for semester: Semester, at index: Int) -> CourseListViewModel {
        if let viewModel = courseListViewModels[semester.id] { return viewModel }

        guard let user = user else { fatalError() }

        let viewModel = CourseListViewModel(user: user, semester: semester, respectsCollapsedState: true,
                                            showsHiddenCourses: UserDefaults.studKit.showsHiddenCourses)
        viewModel.delegate = self
        viewModel.fetch()
        viewModel.update()

        courseListViewModels[semester.id] = viewModel
        courseListViewModelIndexCache[semester.id] = index

        return viewModel
    }

    private var courseListViewModelIndexCache = [String: Int]()

    private func index(for courseListViewModel: CourseListViewModel) -> Int? {
        for index in 0 ..< tableView.numberOfSections {
            guard
                let header = tableView.headerView(forSection: index) as? SemesterHeader,
                header.courseListViewModel === courseListViewModel
            else { continue }
            courseListViewModelIndexCache[courseListViewModel.semester?.id ?? ""] = index
            return index
        }
        return courseListViewModelIndexCache[courseListViewModel.semester?.id ?? ""]
    }

    private func pruneCourseListViewModels() {
        let existingSemesterIds = Set(viewModel?.map { $0.id } ?? [])
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

        let isEmpty = viewModel?.isEmpty ?? false

        emptyViewTitleLabel.text = "It Looks Like There Are No Semesters".localized
        emptyViewSubtitleLabel.text = "You can try to reload the semesters from Stud.IP.".localized
        emptyViewActionButton.setTitle("Reload".localized, for: .normal)

        tableView.backgroundView = isEmpty ? emptyView : nil
        tableView.separatorStyle = isEmpty ? .none : .singleLine
        tableView.bounces = !isEmpty

        if let navigationBarHeight = navigationController?.navigationBar.bounds.height {
            emptyViewTopConstraint.constant = navigationBarHeight * 2 + 32
        }
    }

    private func presentColorPicker(for cell: CourseCell) {
        let route = Routes.colorPicker(sender: cell) { id, _ in
            guard let user = self.user else { return }

            cell.course.set(groupId: id, for: user) { result in
                guard result.isSuccess else { return }
                UISelectionFeedbackGenerator().selectionChanged()
            }

            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
        performSegue(withRoute: route)
    }

    @available(iOS 11.0, *)
    private func colorAction(for cell: CourseCell?) -> UIContextualAction? {
        guard user?.organization.supportsSettingCourseGroups ?? false else { return nil }

        let action = UIContextualAction(style: .normal, title: "Color".localized) { _, _, success in
            success(cell?.color(nil) ?? false)
        }
        action.backgroundColor = cell?.colorView.backgroundColor ?? UI.Colors.studBlue
        action.image = #imageLiteral(resourceName: "ColorActionGlyph")
        return action
    }

    @available(iOS 11.0, *)
    private func hideAction(for cell: CourseCell?) -> UIContextualAction? {
        let action = UIContextualAction(style: .destructive, title: "Hide".localized) { _, _, success in
            success(cell?.hide(nil) ?? false)
        }
        action.backgroundColor = UI.Colors.studRed
        action.image = #imageLiteral(resourceName: "HideActionGlyph")
        return action
    }

    // MARK: - User Interaction

    @IBAction
    func userButtonTapped(_ sender: Any) {
        (tabBarController as? AppController)?.userButtonTapped(sender)
    }

    @IBAction
    func refreshControlTriggered(_: Any) {
        viewModel?.update(forced: true) {
            self.refreshControl?.endRefreshing()
        }
    }

    @IBAction
    func emptyViewActionButtonTapped(_: Any) {
        viewModel?.update(forced: true)
    }
}

// MARK: - Popover Presentation

extension CourseListController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
