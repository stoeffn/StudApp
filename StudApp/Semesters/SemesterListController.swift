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

final class SemesterListController: UITableViewController, DataSourceSectionDelegate, Routable {
    private var viewModel: SemesterListViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.title = Strings.Terms.courses.localized

        tableView.tableFooterView = nil

        updateEmptyView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.update()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in self.updateEmptyView() }, completion: nil)
    }

    // MARK: - Navigation

    func prepareContent(for route: Routes) {
        guard case let .semesterList(for: user) = route else { fatalError() }

        viewModel = SemesterListViewModel(organization: user.organization, respectsHiddenStates: false)
        viewModel.delegate = self
        viewModel.fetch()
    }

    // MARK: - Table View Data Source

    private enum Sections: Int {
        case settings, semesters

        var cellIdentifier: String {
            switch self {
            case .settings: return "SettingCell"
            case .semesters: return "SemesterCell"
            }
        }
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Sections.settings.rawValue: return 1
        case Sections.semesters.rawValue: return viewModel.numberOfRows
        default: fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Sections.settings.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: Sections.settings.cellIdentifier, for: indexPath)
            cell.textLabel?.text = Strings.Actions.showHiddenCourses.localized
            cell.accessoryType = UserDefaults.studKit.showsHiddenCourses ? .checkmark : .none
            return cell
        case Sections.semesters.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: Sections.semesters.cellIdentifier, for: indexPath)
            let semester = viewModel[rowAt: indexPath.row]
            let beginsAt = semester.beginsAt.formatted(using: .monthAndYear)
            let endsAt = semester.endsAt.formatted(using: .monthAndYear)
            cell.textLabel?.text = semester.title
            cell.detailTextLabel?.text = Strings.Formats.range.localized(beginsAt, endsAt)
            cell.detailTextLabel?.accessibilityLabel = Strings.Formats.fromTo.localized(beginsAt, endsAt)
            cell.accessoryType = semester.state.isHidden ? .none : .checkmark
            return cell
        default:
            fatalError()
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Sections.settings.rawValue: return Strings.Terms.settings.localized
        case Sections.semesters.rawValue: return Strings.Terms.semesters.localized
        default: fatalError()
        }
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case Sections.settings.rawValue:
            UserDefaults.studKit.showsHiddenCourses = !UserDefaults.studKit.showsHiddenCourses
            cell?.accessoryType = UserDefaults.studKit.showsHiddenCourses ? .checkmark : .none
        case Sections.semesters.rawValue:
            let semester = viewModel[rowAt: indexPath.row]
            semester.state.isHidden = !semester.state.isHidden
            cell?.accessoryType = semester.state.isHidden ? .none : .checkmark
        default:
            fatalError()
        }
    }

    // MARK: - Data Source Delegate

    func data<Section: DataSourceSection>(changedIn _: Section.Row, at index: Int, change: DataChange<Section.Row, Int>,
                                          in section: Section) {
        let indexPath = IndexPath(row: index, section: Sections.semesters.rawValue)
        switch change {
        case .insert:
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath], with: .fade)
        case let .move(newIndex):
            let newIndexPath = IndexPath(row: newIndex, section: Sections.semesters.rawValue)
            tableView.moveRow(at: indexPath, to: newIndexPath)
        }
    }

    func dataDidChange<Section>(in _: Section) {
        tableView.endUpdates()
        updateEmptyView()
    }

    // MARK: - User Interface

    @IBOutlet var emptyView: UIView!

    @IBOutlet var emptyViewTopConstraint: NSLayoutConstraint!

    @IBOutlet var emptyViewTitleLabel: UILabel!

    @IBOutlet var emptyViewSubtitleLabel: UILabel!

    @IBOutlet var emptyViewActionButton: UIButton!

    private func updateEmptyView() {
        guard view != nil else { return }

        emptyViewTitleLabel.text = Strings.Callouts.noSemesters.localized
        emptyViewSubtitleLabel.text = Strings.Callouts.noSemestersSubtitle.localized
        emptyViewActionButton.setTitle(Strings.Actions.reload.localized, for: .normal)

        tableView.backgroundView = viewModel.isEmpty ? emptyView : nil
        tableView.separatorStyle = viewModel.isEmpty ? .none : .singleLine
        tableView.bounces = !viewModel.isEmpty

        if let navigationBarHeight = navigationController?.navigationBar.bounds.height {
            emptyViewTopConstraint.constant = navigationBarHeight * 2 + 32
        }
    }

    // MARK: - User Interaction

    @IBAction
    func doneButtonTapped(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction
    func emptyViewActionButtonTapped(_: Any) {
        viewModel.update()
    }
}
