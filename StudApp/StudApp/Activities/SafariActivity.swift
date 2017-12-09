//
//  SafariActivity.swift
//  StudApp
//
//  Created by Steffen Ryll on 09.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class SafariActivity: UIActivity, ByTypeNameIdentifiable {
    private var url: URL?

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
        UIApplication.shared.open(url, options: [:], completionHandler: activityDidFinish)
    }
}
