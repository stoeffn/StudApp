//
//  AnnouncementController.swift
//  StudApp
//
//  Created by Steffen Ryll on 21.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit
import StudKitUI
import WebKit

final class AnnouncementController: UIViewController, Routable {
    private let htmlContentService = ServiceContainer.default[HtmlContentService.self]
    private var announcement: Announcement!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initUserInterface()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.title = announcement.title

        contentView.loadHTMLString(htmlContentService.styledHtmlContent(for: announcement.htmlContent), baseURL: nil)
    }

    // MARK: - Navigation

    func prepareContent(for route: Routes) {
        guard case let .announcement(announcement) = route else { return }
        self.announcement = announcement
    }

    // MARK: - User Interface

    private lazy var contentView = htmlContentService.view()

    private func initUserInterface() {
        view.addSubview(contentView)
        contentView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    // MARK: - User Interaction

    @IBAction
    private func doneButtonTapped(_: Any) {
        dismiss(animated: true, completion: nil)
    }
}
