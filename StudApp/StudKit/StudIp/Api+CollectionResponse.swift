//
//  Api+CollectionResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

private let defaultNumberOfItemsPerRequest = 20

extension Api {
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
