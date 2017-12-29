//
//  EventListController.swift
//  StudApp
//
//  Created by Steffen Ryll on 26.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class EventListController: UITableViewController, DataSourceDelegate, Routable {
    private var viewModel: EventListViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = UIEdgeInsets(top: dateTabBar.bounds.height, left: 0, bottom: 0, right: 0)
        }

        navigationItem.title = "Events".localized

        tableView.register(DateHeader.self, forHeaderFooterViewReuseIdentifier: DateHeader.typeIdentifier)
        tableView.tableHeaderView = nil

        dateTabBar.isDateEnabled = viewModel.contains
        dateTabBar.didSelectDate = { date in
            guard let sectionIndex = self.viewModel.sectionIndex(for: date) else { return }
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: sectionIndex), at: .top, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let navigationController = splitViewController?.detailNavigationController as? BorderlessNavigationController
        navigationController?.toolBarView = dateTabBarContainer

        if let nowIndexPath = viewModel.nowIndexPath {
            tableView.scrollToRow(at: nowIndexPath, at: .top, animated: true)
        }

        updateDateTabBar()

        viewModel.update()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let nowIndexPath = viewModel.nowIndexPath {
            tableView.scrollToRow(at: nowIndexPath, at: .top, animated: true)
            updateDateTabBarSelection()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let navigationController = splitViewController?.detailNavigationController as? BorderlessNavigationController
        navigationController?.toolBarView = nil
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let navigationController = splitViewController?.detailNavigationController as? BorderlessNavigationController
        navigationController?.toolBarView = nil

        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in }, completion: { _ in
            let navigationController = self.splitViewController?.detailNavigationController as? BorderlessNavigationController
            navigationController?.toolBarView = self.dateTabBarContainer
        })
    }

    func prepareDependencies(for route: Routes) {
        guard case let .eventsInCourse(course) = route else { fatalError() }

        viewModel = EventListViewModel(course: course)
        viewModel.delegate = self
        viewModel.fetch()
    }

    // MARK: - Restoration

    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(viewModel.course.objectIdentifier.rawValue, forKey: ObjectIdentifier.typeIdentifier)
        super.encode(with: coder)
    }

    override func decodeRestorableState(with coder: NSCoder) {
        if let restoredObjectIdentifier = coder.decodeObject(forKey: ObjectIdentifier.typeIdentifier) as? String,
            let course = Course.fetch(byObjectId: ObjectIdentifier(rawValue: restoredObjectIdentifier)) {
            viewModel = EventListViewModel(course: course)
            viewModel.delegate = self
            viewModel.fetch()
        }

        super.decodeRestorableState(with: coder)
    }

    // MARK: - User Interface

    @IBOutlet weak var dateTabBarContainer: UIView!

    @IBOutlet weak var dateTabBar: DateTabBar!

    private func updateDateTabBar() {
        dateTabBar?.startsAt = viewModel[sectionAt: 0]
        dateTabBar?.endsAt = viewModel[sectionAt: viewModel.numberOfSections - 1]
        dateTabBar?.reloadData()
        updateDateTabBarSelection()
    }

    private func updateDateTabBarSelection() {
        guard let indexPath = tableView.topMostIndexPath else { return }
        dateTabBar?.selectedDate = viewModel[sectionAt: indexPath.section]
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in _: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.typeIdentifier, for: indexPath)
        (cell as? EventCell)?.event = viewModel[rowAt: indexPath]
        return cell
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return DateHeader.height
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: DateHeader.typeIdentifier)
        (header as? DateHeader)?.date = viewModel[sectionAt: section]
        return header
    }

    // MARK: - Scroll View Delegate

    override func scrollViewDidEndDecelerating(_: UIScrollView) {
        updateDateTabBarSelection()
    }

    // MARK: - Reacting to Data Changes

    func dataDidChange<Source>(in _: Source) {
        tableView.endUpdates()
        updateDateTabBar()
        updateDateTabBarSelection()
    }
}
