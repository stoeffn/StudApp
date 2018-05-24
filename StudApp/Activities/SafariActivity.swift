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
        return Strings.Actions.openInSafari.localized
    }

    override var activityImage: UIImage {
        return #imageLiteral(resourceName: "OpenInSafariActivityGlyph")
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return !activityItems
            .compactMap { $0 as? URL }
            .filter { UIApplication.shared.canOpenURL($0) }
            .isEmpty
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        url = activityItems
            .compactMap { $0 as? URL }
            .first
    }

    override func perform() {
        guard let url = url else { return activityDidFinish(false) }

        guard let controller = controller else {
            return UIApplication.shared.open(url, options: [:], completionHandler: activityDidFinish)
        }

        guard let safariController = htmlContentService.safariViewController(for: url) else { return }
        controller.present(safariController, animated: true) {
            self.activityDidFinish(true)
        }
    }
}
