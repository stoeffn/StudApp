//
//  PreviewController.swift
//  StudApp
//
//  Created by Steffen Ryll on 02.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import QuickLook
import StudKit

final class PreviewController: QLPreviewController, Routable {
    // MARK: - Life Cycle

    private var file: File!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userActivity = userActivity()
    }

    func prepareDependencies(for route: Routes) {
        guard case let .preview(file) = route else { fatalError() }

        self.file = file

        dataSource = self
    }

    // MARK: - Supporting User Activities

    func userActivity() -> NSUserActivity {
        let activity = NSUserActivity(activityType: UserActivities.documentIdentifier)
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = true
        activity.title = file.title
        activity.webpageURL = file.url
        activity.keywords = file.keywords
        activity.requiredUserInfoKeys = [File.typeIdentifier]
        return activity
    }

    override func updateUserActivityState(_ activity: NSUserActivity) {
        activity.addUserInfoEntries(from: [File.typeIdentifier: file.id])
    }
}

// MARK: - QuickLook Data Source

extension PreviewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in _: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_: QLPreviewController, previewItemAt _: Int) -> QLPreviewItem {
        return file
    }
}
