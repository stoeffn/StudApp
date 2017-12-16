//
//  StoreRoutes.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

enum StoreRoutes: ApiRoutes {
    case verify(receipt: Data)

    var path: String {
        switch self {
        case .verify: return "verify-receipt"
        }
    }

    var body: Data? {
        switch self {
        case let .verify(receipt): return receipt
        }
    }

    var type: Decodable.Type? {
        switch self {
        case .verify: return StoreService.State.self
        }
    }
}
