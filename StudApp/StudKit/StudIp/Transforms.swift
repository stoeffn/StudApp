//
//  Transforms.swift
//  StudKit
//
//  Created by Steffen Ryll on 04.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

enum StudIp {
    static func transformIdPath(_ path: String?) -> String? {
        return path?
            .components(separatedBy: "/")
            .last?
            .nilWhenEmpty
    }

    static func transformCourseNumber(_ rawNumber: String?) -> String? {
        return rawNumber?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilWhenEmpty
    }

    static func transformCourseSummary(_ summary : String?) -> String? {
        return summary?
            .replacingMatches("<[^>]+>", with: "")
            .replacingMatches("Literatur: $", with: "")
            .decodedHTML
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilWhenEmpty
    }
}
