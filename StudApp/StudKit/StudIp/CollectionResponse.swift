//
//  CollectionResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Decoded representation of a generic Stud.IP API response that encapsulates a paginated collection.
struct CollectionResponse<Element: Decodable>: Decodable {
    struct Pagination: Decodable {
        let total: Int
        let offset: Int
        let limit: Int

        var nextOffset: Int? {
            let nextOffset = offset + limit
            return nextOffset < total ? nextOffset : nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case collection, pagination
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            items = Array(try container.decode([String: Element].self, forKey: .collection).values)
        } catch {
            items = try container.decode([Element].self, forKey: .collection)
        }

        pagination = try container.decode(Pagination.self, forKey: .pagination)
    }

    let items: [Element]

    let pagination: Pagination
}
