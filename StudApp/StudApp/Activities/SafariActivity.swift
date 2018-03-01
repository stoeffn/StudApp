//
//  SafariActivity.swift
//  StudApp
//
//  Created by Steffen Ryll on 09.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import SafariServices
import StudKit
import StudKitUI

final class SafariActivity: UIActivity, ByTypeNameIdentifiable {
    private let htmlContentService = ServiceContainer.default[HtmlContentService.self]
    private weak var controller: UIViewController?
    private var url: URL?

    init(controller: UIViewController? = nil) {
        self.controller = controller
    }

    override var activityType: UIActivityType? {
        return UIActivityType(SafariActivity.typeIdentifier)
    }

    override var activityTitle: String {
        return "Open in Safari".localized
    }

    override var activityImage: UIImage {
        return #imageLiteral(resourceName: "OpenInSafariActivityGlyph")
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return !activityItems
            .flatMap { $0 as? URL }
            .filter { UIApplication.shared.canOpenURL($0) }
            .isEmpty
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        url = activityItems
            .flatMap { $0 as? URL }
            .first
    }

    override func perform() {
        guard let url = url else { return activityDidFinish(false) }

        guard let controller = controller else {
            return UIApplication.shared.open(url, options: [:], completionHandler: activityDidFinish)
        }

        let safariController = htmlContentService.safariViewController(for: url)
        controller.present(safariController, animated: true) {
            self.activityDidFinish(true)
        }
    }
}
