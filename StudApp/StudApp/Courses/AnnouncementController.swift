//
//  AnnouncementController.swift
//  StudApp
//
//  Created by Steffen Ryll on 21.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class AnnouncementController: UITableViewController, Routable {
    private var announcement: Announcement!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = announcement.title
    }

    func prepareDependencies(for route: Routes) {
        guard case let .announcement(announcement) = route else { return }
        self.announcement = announcement
    }
}
