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

    static func decodeDate<CodingKeys>(in container: KeyedDecodingContainer<CodingKeys>,
                                                           forKey key: KeyedDecodingContainer<CodingKeys>.Key) throws -> Date {
        if let timeInterval = try? container.decode(Int.self, forKey: key) {
            return Date(timeIntervalSince1970: TimeInterval(timeInterval))
        }

        let rawTimeInterval = try container.decode(String.self, forKey: key)
        guard let timeInterval = TimeInterval(rawTimeInterval) else {
            let description = "Cannot create time interval from '\(rawTimeInterval)'"
            let context = DecodingError.Context(codingPath: [key], debugDescription: description, underlyingError: nil)
            throw DecodingError.typeMismatch(TimeInterval.self, context)
        }
        return Date(timeIntervalSince1970: timeInterval)
    }
}
