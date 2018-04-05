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

import Foundation
@testable import StudKit

struct Test: Decodable {
    let id: String
}

enum TestRoutes: String, TestableApiRoutes {
    case object
    case collection
    case failingCollection

    static let objectData = """
        {
            "id": "42"
        }
    """.data(using: .utf8)!

    static let collection0Data = """
        {
            "collection": {
                "0": {
                    "id": "0"
                }
            },
            "pagination": {
                "total": 11,
                "offset": 0,
                "limit": 5
            }
        }
    """.data(using: .utf8)!

    static let collection1Data = """
        {
            "collection": {
                "1": {
                    "id": "1"
                }
            },
            "pagination": {
                "total": 11,
                "offset": 5,
                "limit": 5
            }
        }
    """.data(using: .utf8)!

    static let collection2Data = """
        {
            "collection": {
                "2": {
                    "id": "2"
                }
            },
            "pagination": {
                "total": 11,
                "offset": 10,
                "limit": 5
            }
        }
    """.data(using: .utf8)!

    var identifier: String {
        return ""
    }

    var path: String {
        return rawValue
    }

    var type: Decodable.Type? {
        switch self {
        case .object: return Test.self
        case .collection, .failingCollection: return CollectionResponse<Test>.self
        }
    }

    func testData(for parameters: [URLQueryItem]) throws -> Data {
        switch self {
        case .object:
            return TestRoutes.objectData
        case .collection, .failingCollection:
            guard let offset = parameters.filter({ $0.name == "offset" }).first?.value else {
                fatalError("Offset parameters missing in collection data test call.")
            }
            switch offset {
            case "0":
                return TestRoutes.collection0Data
            case "5":
                if self == .failingCollection {
                    throw NSError(domain: "abc", code: 0)
                }
                return TestRoutes.collection1Data
            case "10":
                return TestRoutes.collection2Data
            default:
                fatalError("No collection test data for offset '\(offset)'.")
            }
        }
    }
}
