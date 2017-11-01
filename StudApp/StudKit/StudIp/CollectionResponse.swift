//
//  CollectionResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

struct CollectionResponse<Element : Decodable> : Decodable {
    struct Pagination : Decodable {
        let total: Int
        let offset: Int
        let limit: Int

        var nextOffset: Int? {
            let nextOffset = offset + limit
            return nextOffset < total ? nextOffset : nil
        }
    }

    enum CodingKeys : String, CodingKey {
        case collection, pagination
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let collection = try values.decode([String: Element].self, forKey: .collection)
        items = Array(collection.values)
        pagination = try values.decode(Pagination.self, forKey: .pagination)
    }

    let items: [Element]

    let pagination: Pagination
}
