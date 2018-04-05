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

private let defaultNumberOfItemsPerRequest = 64

extension Api {
    /// Requests data from this API and interprets it as a paginated collection.
    ///
    /// - Parameters:
    ///   - route: Route to request data from.
    ///   - offset: Pagination offset, i.e. the number of items to skip. Defaults to `0`.
    ///   - itemsPerRequest: Number of items you want to receive from the API in one response. Defaults to
    ///                      `defaultNumberOfItemsPerRequest`.
    ///   - completion: Completion handler receiving a result with the decoded collection response containing a list of decoded
    ///                 data.
    /// - Returns: URL task in its resumed state or `nil` if building the request failed.
    /// - Precondition: `route`'s type must not be `nil`.
    /// - Remark: At the moment, this method supports JSON decoding only.
    @discardableResult
    func requestCollectionPage<Result>(_ route: Routes, afterOffset offset: Int = 0,
                                       itemsPerRequest: Int = defaultNumberOfItemsPerRequest,
                                       completion: @escaping ResultHandler<CollectionResponse<Result>>) -> URLSessionTask? {
        let offsetQuery = URLQueryItem(name: "offset", value: String(offset))
        let limitQuery = URLQueryItem(name: "limit", value: String(itemsPerRequest))
        return requestDecoded(route, parameters: [offsetQuery, limitQuery]) { completion($0) }
    }

    /// Requests all data from a paginated collection in this API by iterating every page.
    ///
    /// - Parameters:
    ///   - route: Route to request data from.
    ///   - offset: Pagination offset, i.e. the number of items to skip. Defaults to `0`.
    ///   - itemsPerRequest: Number of items you want to receive from the API in one response. Defaults to
    ///                      `defaultNumberOfItemsPerRequest`.
    ///   - initialItems: Items that were already received from the API. As this method calls itself recursively, this argument
    ///                   is used for appending data from previous requests. Usually, you should use its default empty value.
    ///   - completion: Completion handler receiving a result with the decoded collection contents.
    /// - Precondition: `route`'s type must not be `nil`.
    /// - Remark: At the moment, this method supports JSON decoding only. Due to issueing multiple requests, this method does
    ///           not return a single session task.
    func requestCollection<Value: Decodable>(_ route: Routes, afterOffset offset: Int = 0,
                                             itemsPerRequest: Int = defaultNumberOfItemsPerRequest,
                                             items initialItems: [Value] = [],
                                             completion: @escaping ResultHandler<[Value]>) {
        requestCollectionPage(route, afterOffset: offset,
                              itemsPerRequest: itemsPerRequest) { (result: Result<CollectionResponse<Value>>) in
            guard let collection = result.value else {
                return completion(.failure(result.error))
            }

            let items = initialItems + collection.items
            if let offset = collection.pagination.nextOffset {
                self.requestCollection(route, afterOffset: offset, items: items, completion: completion)
            } else {
                completion(result.map { _ in items })
            }
        }
    }
}
