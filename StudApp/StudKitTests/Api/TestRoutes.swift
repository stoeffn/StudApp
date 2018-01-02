//
//  TestRoutes.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 27.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
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
