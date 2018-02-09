//
//  NSMutableAttributedString+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension NSMutableAttributedString {
    public func addLink(for title: String, to url: URL?) {
        guard let url = url, let range = string.range(of: title) else { return }
        addAttribute(.link, value: url, range: NSRange(range, in: title))
    }
}
