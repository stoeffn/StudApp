//
//  HtmlContentService.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 01.03.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import WebKit

public final class HtmlContentService {
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

    public func view() -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = false

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

        let view = WKWebView(frame: .zero, configuration: configuration)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
