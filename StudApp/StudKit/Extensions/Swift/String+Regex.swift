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
