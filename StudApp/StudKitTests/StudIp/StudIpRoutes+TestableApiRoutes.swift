//
//  StudIpRoutes+TestableApiRoutes.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit

extension StudIpRoutes: TestableApiRoutes {
    func testData(for parameters: [URLQueryItem]) throws -> Data {
        let offset = parameters.filter({ $0.name == "offset" }).first?.value ?? "0"
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
        default: fatalError("No Mock API data for route '\(self)' and offset '\(offset)'.")
        }
    }
}
