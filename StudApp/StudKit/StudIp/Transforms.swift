//
//  Transforms.swift
//  StudKit
//
//  Created by Steffen Ryll on 04.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

enum StudIp {
    /// Returns the id from a path with an id as its last component.
    ///
    /// For testing purposes, paths starting with "$" will be returned completely, except for the leading dollar sign.
    ///
    /// ## Examples
    /// - "/api/rooms/abc", 2 -> "abc"
    /// - "/api/rooms/abc/test", 2 -> "abc"
    /// - "api/rooms/", 2 -> `nil`
    static func transformIdPath(_ path: String?, idComponentIndex: Int) -> String? {
        guard let path = path else { return nil }

        guard path.first != "$" else { return String(path.dropFirst()) }

        let components = path
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .components(separatedBy: "/")
        guard components.count > idComponentIndex else { return nil }
        return components[idComponentIndex].nilWhenEmpty
    }

    /// Returns the input with trimmed whitespace.
    static func transformCourseNumber(_ rawNumber: String?) -> String? {
        return rawNumber?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilWhenEmpty
    }

    /// Returns the input, decoding HTML characters, removing HTML tags and special prefixes, as well as
    /// trimming whitespace.
    static func transformCourseSummary(_ summary: String?) -> String? {
        return summary?
            .replacingMatches("<[^>]+>", with: "")
            .replacingMatches("Literatur: *$", with: "")
            .decodedHTML
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilWhenEmpty
    }
}
