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
