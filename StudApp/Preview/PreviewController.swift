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

import QuickLook
import StudKit
import StudKitUI

final class PreviewController: QLPreviewController, Routable {
    private var coreDataService = ServiceContainer.default[CoreDataService.self]
    private var historyService = ServiceContainer.default[PersistentHistoryService.self]

    // MARK: - Life Cycle

    private var file: File!

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self

        file.download { result in
            guard result.isSuccess else {
                let title = result.error?.localizedDescription ?? "Something went wrong downloading \"%@\"".localized(self.file.title)
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
                return self.present(alert, animated: true, completion: nil)
            }

            if self.file.isNew {
                self.file.isNew = false
            }

            self.refreshCurrentPreviewItem()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userActivity = file.userActivity
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        ServiceContainer.default[StoreService.self].requestReview()

        try? historyService.mergeHistory(into: coreDataService.viewContext)
        try? historyService.deleteHistory(mergedInto: Targets.iOSTargets, in: coreDataService.viewContext)
    }

    // MARK: - Navigation

    func prepareContent(for route: Routes) {
        guard case let .preview(for: file, delegate) = route else { fatalError() }
        self.file = file
        self.delegate = delegate
    }

    // MARK: - Supporting User Activities

    override func updateUserActivityState(_ activity: NSUserActivity) {
        activity.objectIdentifier = file.objectIdentifier
    }

    // MARK: - Working With 3D Touch Previews and Preview Quick Actions

    override var previewActionItems: [UIPreviewActionItem] {
        guard file.state.isDownloaded else { return [] }
        return [
            UIPreviewAction(title: "Remove".localized, style: .destructive) { _, _ in
                try? self.file.removeDownload()
            },
        ]
    }

    // MARK: - Utilities

    static func controllerForDownloadOrPreview(_ file: File, delegate: QLPreviewControllerDelegate,
                                               handler: @escaping (UIViewController?) -> Void) {
        if let externalUrl = file.externalUrl, !file.isLocationSecure {
            if file.isNew {
                file.isNew = false
            }
            return handler(ServiceContainer.default[HtmlContentService.self].safariViewController(for: externalUrl))
        }

        guard file.state.isMostRecentVersionDownloaded else {
            file.download { result in
                guard result.isFailure else { return UINotificationFeedbackGenerator().notificationOccurred(.success) }

                let title = result.error?.localizedDescription ?? "Something went wrong downloading \"%@\"".localized(file.title)
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
                return handler(alert)
            }
            return
        }

        let previewController = PreviewController()
        previewController.prepareContent(for: .preview(for: file, delegate))
        handler(previewController)
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
