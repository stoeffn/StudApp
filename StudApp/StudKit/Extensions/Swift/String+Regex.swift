//
//  String+Regex.swift
//  StudKit
//
//  Created by Steffen Ryll on 04.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

extension String {
    /// Apply a regular expression pattern to a copy of this string.
    ///
    /// - Parameters:
    ///   - pattern: Regular Expression
    ///   - template: A template string that each match will be replaced with; Matched groups get interpolated by using
    ///               `$0`, `$1`, ... in the template string
    /// - Returns: A new, modified string
    func replacingMatches(_ pattern: String, with template: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return self }
        let range = NSRange(location: 0, length: count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: template)
    }

    /// Apply a regular expression pattern to this string.
    ///
    /// - Parameters:
    ///   - pattern: Regular Expression
    ///   - template: A template string that each match will be replaced with; Matched groups get interpolated by using
    ///               `$0`, `$1`, ... in the template string
    /// - Returns: `self`
    @discardableResult
    mutating func replaceMatches(_ pattern: String, with template: String) -> String {
        self = replacingMatches(pattern, with: template)
        return self
    }
}
