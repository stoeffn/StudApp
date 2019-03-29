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

extension StudIpRoutes: TestableApiRoutes {
    func testData(for parameters: [URLQueryItem]) throws -> Data {
        let offset = parameters.filter { $0.name == "offset" }.first?.value ?? "0"
        switch self {
        case .semesters:
            return Data(fromJsonResource: "semesterCollection")
        case .courses:
            switch offset {
            case "0": return Data(fromJsonResource: "courseCollection")
            case "20": return Data(fromJsonResource: "courseCollection+20")
            default: fatalError("No Mock API data for route '\(self)' and offset '\(offset)'.")
            }
        case .rootFolderForCourse:
            return Data(fromJsonResource: "fileCollection")
        case .eventsInCourse:
            return Data(fromJsonResource: "eventCollection")
        case .announcementsInCourse:
            return Data(fromJsonResource: "announcementudipsCollection")
        default:
            print("No Mock API data for route '\(self)' and offset '\(offset)'.")
            return Data()
        }
    }
}
