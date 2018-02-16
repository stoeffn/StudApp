//
//  IdentifiableResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

protocol IdentifiableResponse: Hashable {
    var id: String { get }
}

// MARK: - Hashing

extension IdentifiableResponse {
    var hashValue: Int {
        return id.hashValue
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
