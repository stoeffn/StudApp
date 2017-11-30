//
//  StoreViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 30.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StoreKit

public final class StoreViewModel {
    private let storeService = ServiceContainer.default[StoreService.self]

    public init() {}
}
