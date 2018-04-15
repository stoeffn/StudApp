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

@testable import StudKit

extension SemesterResponseTests {
    static let semester0Data = """
        {
            "id": "S0",
            "title": "SS 2009",
            "description": "Summary",
            "begin": 1238364000,
            "end": 1254347999,
            "seminars_begin": 1238364000,
            "seminars_end": 1246744799
        }
    """.data(using: .utf8)!

    static let semester1Data = """
        {
            "id": "S1",
            "title": "SS 2018",
            "description": "",
            "begin": 1238364000,
            "end": 1254347999,
            "seminars_begin": 1238364000,
            "seminars_end": 1246744799
        }
    """.data(using: .utf8)!

    static let semester0 = SemesterResponse(id: "S0", title: "Title", beginsAt: Date(timeIntervalSince1970: 1),
                                            endsAt: Date(timeIntervalSince1970: 4), coursesBeginAt: Date(timeIntervalSince1970: 2),
                                            coursesEndAt: Date(timeIntervalSince1970: 3), summary: "Summary")
}
