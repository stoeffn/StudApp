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
                                   itemsPerRequest: Int = defaultNumberOfItemsPerRequest,
                                   completionHandler: @escaping ResultCallback<CollectionResponse<Result>>) -> Progress {
        let offsetQuery = URLQueryItem(name: "offset", value: String(offset))
        let limitQuery = URLQueryItem(name: "limit", value: String(itemsPerRequest))
        return requestDecoded(route, parameters: [offsetQuery, limitQuery]) { result in
            completionHandler(result)
        }
    }

    func requestCompleteCollection<Value: Decodable>(_ route: Routes, afterOffset offset: Int = 0,
                                                     itemsPerRequest: Int = defaultNumberOfItemsPerRequest,
                                                     items initialItems: [Value] = [],
                                                     completionHandler: @escaping ResultCallback<[Value]>) {
        requestCollection(route, afterOffset: offset, itemsPerRequest: itemsPerRequest) { (result: Result<CollectionResponse<Value>>) in
            guard let collection = result.value else {
                return completionHandler(result.replacingValue(nil))
            }
            let items = initialItems + collection.items
            if let offset = collection.pagination.nextOffset {
                self.requestCompleteCollection(route, afterOffset: offset, items: items, completionHandler: completionHandler)
            } else {
                completionHandler(result.replacingValue(items))
            }
        }
    }
}
