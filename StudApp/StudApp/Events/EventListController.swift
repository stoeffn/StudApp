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

        navigationItem.title = "Events".localized
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.update()
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

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.typeIdentifier, for: indexPath)
        (cell as? EventCell)?.event = viewModel[rowAt: indexPath]
        return cell
    }
}
