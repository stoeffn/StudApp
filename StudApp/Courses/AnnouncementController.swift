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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ServiceContainer.default[StoreService.self].requestReview()
    }

    // MARK: - Navigation

    func prepareContent(for route: Routes) {
        guard case let .announcement(announcement) = route else { return }
        self.announcement = announcement
    }

    // MARK: - User Interface

    private lazy var contentView = htmlContentService.view()

    private func initUserInterface() {
        navigationItem.title = announcement.title

        view.addSubview(contentView)
        contentView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.navigationDelegate = self
        contentView.alpha = 0
        contentView.loadHTMLString(htmlContentService.styledHtmlContent(for: announcement.htmlContent), baseURL: nil)
        contentView.accessibilityLabel = announcement.textContent
    }
}

// MARK: - Navigation Delegate

extension AnnouncementController: WKNavigationDelegate {
    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard navigationAction.navigationType != .other else { return decisionHandler(.allow) }

        defer { decisionHandler(.cancel) }
        guard
            let url = navigationAction.request.url,
            let controller = htmlContentService.safariViewController(for: url)
        else { return }
        present(controller, animated: true, completion: nil)
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        UIView.animate(withDuration: UI.defaultAnimationDuration) {
            self.contentView.alpha = 1
        }
    }
}
