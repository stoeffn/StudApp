//
//  StudIp.swift
//  StudKit
//
//  Created by Steffen Ryll on 04.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

enum StudIp {

    // MARK: - Custom Transforms

    static func transform(idPath: String?) -> String? {
        return try! idPath?.firstMatch(for: "([a-f0-9]{32}|[A-Z][0-9]+)")
    }

    /// Returns the input with trimmed whitespace.
    static func transform(courseNumber: String?) -> String? {
        return courseNumber?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilWhenEmpty
    }

    /// Returns the input, decoding HTML characters, removing HTML tags and special prefixes, as well as
    /// trimming whitespace.
    static func transform(courseSummary: String?) -> String? {
        return try! courseSummary?
            .replacingMatches(for: "<[^>]+>", with: "")
            .replacingMatches(for: "Literatur: *$", with: "")
            .decodedHTML
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilWhenEmpty
    }

    static func transform(location: String?) -> String? {
        var charactersToTrim = CharacterSet.whitespacesAndNewlines
        charactersToTrim.insert(charactersIn: "()")
        return try! location?
            .replacingMatches(for: " *, *", with: "\n")
            .replacingOccurrences(of: "Gebaeude", with: "Gebäude")
            .trimmingCharacters(in: charactersToTrim)
            .nilWhenEmpty
    }

    // MARK: - Custom Decoding

    static func decodeTimeIntervalStringAsDate<CodingKeys>(in container: KeyedDecodingContainer<CodingKeys>,
                                                           forKey key: KeyedDecodingContainer<CodingKeys>.Key) throws -> Date {
        let string = try container.decode(String.self, forKey: key)
        guard let timeInterval = TimeInterval(string) else {
            let context = DecodingError.Context(
                codingPath: [key], debugDescription: "Cannot create time interval from '\(string)'", underlyingError: nil)
            throw DecodingError.typeMismatch(TimeInterval.self, context)
        }
        return Date(timeIntervalSince1970: timeInterval)
    }
}
