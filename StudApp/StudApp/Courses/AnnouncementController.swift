//
//  AnnouncementController.swift
//  StudApp
//
//  Created by Steffen Ryll on 21.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class AnnouncementController: UIViewController, Routable {
    private var announcement: Announcement!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = announcement.title

        bodyView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        bodyView.text = announcement.body
    }

    func prepareDependencies(for route: Routes) {
        guard case let .announcement(announcement) = route else { return }
        self.announcement = announcement
    }

    // MARK: - User Interface

    @IBOutlet weak var bodyView: UITextView!

    // MARK: - User Interaction

    @IBAction
    func doneButtonTapped(_: Any) {
        dismiss(animated: true, completion: nil)
    }
}
