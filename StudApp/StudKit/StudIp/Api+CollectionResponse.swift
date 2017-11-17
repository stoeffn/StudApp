//
//  Api+CollectionResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

private let defaultNumberOfItemsPerRequest = 20

extension Api {
    /// Requests data from this API and interprets it as a paginated collection.
    ///
    /// - Parameters:
    ///   - route: Route to request data from.
    ///   - offset: Pagination offset, i.e. the number of items to skip. Defaults to `0`.
    ///   - itemsPerRequest: Number of items you want to receive from the API in one response. Defaults to
    ///                      `defaultNumberOfItemsPerRequest`.
    ///   - ignoreLastAccess: Whether to ignore the route's expiry policy. Defaults to `false`.
    ///   - handler: Completion handler receiving a result with the decoded collection response containing a list of decoded
    ///              data.
    /// - Returns: URL task in its resumed state or `nil` if the route is not expired.
    /// - Precondition: `route`'s type must not be `nil`.
    /// - Remark: At the moment, this method supports JSON decoding only.
    @discardableResult
    func requestCollection<Result>(_ route: Routes, afterOffset offset: Int = 0,
                                   itemsPerRequest: Int = defaultNumberOfItemsPerRequest, ignoreLastAccess: Bool = false,
                                   handler: @escaping ResultHandler<CollectionResponse<Result>>) -> URLSessionTask? {
        let offsetQuery = URLQueryItem(name: "offset", value: String(offset))
        let limitQuery = URLQueryItem(name: "limit", value: String(itemsPerRequest))
        return requestDecoded(route, parameters: [offsetQuery, limitQuery], ignoreLastAccess: ignoreLastAccess) { result in
            handler(result)
        }
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
    ///   - handler: Completion handler receiving a result with the decoded collection contents.
    /// - Precondition: `route`'s type must not be `nil`.
    /// - Remark: At the moment, this method supports JSON decoding only. Due to issueing multiple requests, this method does
    ///           not return a single session task.
    func requestCompleteCollection<Value: Decodable>(_ route: Routes, afterOffset offset: Int = 0,
                                                     itemsPerRequest: Int = defaultNumberOfItemsPerRequest,
                                                     ignoreLastAccess: Bool = false, items initialItems: [Value] = [],
                                                     handler: @escaping ResultHandler<[Value]>) {
        requestCollection(route, afterOffset: offset, itemsPerRequest: itemsPerRequest,
                          ignoreLastAccess: ignoreLastAccess) { (result: Result<CollectionResponse<Value>>) in
            guard let collection = result.value else {
                return handler(result.replacingValue(nil))
            }
            let items = initialItems + collection.items
            if let offset = collection.pagination.nextOffset {
                self.requestCompleteCollection(route, afterOffset: offset, ignoreLastAccess: true, items: items,
                                               handler: handler)
            } else {
                handler(result.replacingValue(items))
            }
        }
    }
}
