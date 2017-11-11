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
    /// Examples:
    /// - "/api/rooms/abc" -> "abc"
    /// - "api/rooms/" -> `nil`
    static func transformIdPath(_ path: String?) -> String? {
        return path?
            .components(separatedBy: "/")
            .last?
            .nilWhenEmpty
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
            .replacingMatches("Literatur: $", with: "")
            .decodedHTML
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilWhenEmpty
    }
}
