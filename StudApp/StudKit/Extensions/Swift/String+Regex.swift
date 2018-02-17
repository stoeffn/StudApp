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
    ///   - pattern: Regular Expression pattern.
    ///   - template: A template string that each match will be replaced with; Matched groups get interpolated by using
    ///               `$0`, `$1`, ... in the template string.
    ///   - options: The matching options to use. See `NSRegularExpression.MatchingOptions` for possible values.
    /// - Returns: A new, modified string.
    func replacingMatches(for pattern: String, with template: String, options: NSRegularExpression.Options = []) throws -> String {
        let regularExpression = try NSRegularExpression(pattern: pattern, options: options)
        let range = NSRange(location: 0, length: count)
        return regularExpression.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: template)
    }

    /// Return the first match of a regular expression in this string.
    ///
    /// - Parameters:
    ///   - pattern: Regular Expression pattern.
    ///   - options: The matching options to use. See `NSRegularExpression.MatchingOptions` for possible values.
    /// - Returns: First match of `pattern`.
    func firstMatch(for pattern: String, options: NSRegularExpression.Options = []) throws -> String? {
        let regularExpression = try NSRegularExpression(pattern: pattern, options: options)
        let range = NSRange(location: 0, length: count)
        guard
            let match = regularExpression.firstMatch(in: self, options: [], range: range),
            let matchRange = Range(match.range, in: self)
        else { return nil }
        return String(self[matchRange])
    }
}
