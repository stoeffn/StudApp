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
import WebKit

public final class HtmlContentService: NSObject {
    private lazy var style: String = {
        guard
            let url = Bundle(for: StudKitUIServiceProvider.self).url(forResource: "HtmlContentStyle", withExtension: "css"),
            let style = try? String(contentsOf: url)
        else { fatalError("Error loading HTML content style.") }
        return style
    }()

    public func styledHtmlContent(for htmlContent: String) -> String {
        return """
        <html>
            <head>
                <meta http-equiv="content-type" content="text/html; charset=utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                <style>
                    \(style)
                </style>
            </head>
            <body>
                \(htmlContent)
            </body>
        </html>
        """
    }

    public func attributedString(for htmlContent: String) -> NSAttributedString? {
        guard let htmlData = styledHtmlContent(for: htmlContent).data(using: .utf8) else { return nil }
        return try? NSAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html],
                                       documentAttributes: nil)
    }

    public func view() -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = false

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

        let view = WKWebView(frame: .zero, configuration: configuration)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.scrollView.delegate = self
        return view
    }

    public func safariViewController(for url: URL) -> SFSafariViewController? {
        guard ["http", "https"].contains(url.scheme?.lowercased()) else { return nil }

        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = UI.Colors.tint
        return controller
    }
}

extension HtmlContentService: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.x != 0 else { return }
        scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y), animated: false)
    }
}
