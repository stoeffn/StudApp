//
//  VerificationViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class VerificationViewModel {
    private let storeService = ServiceContainer.default[StoreService.self]

    public init() {}

    public func verifyStoreState(handler: @escaping ResultHandler<Bool>) {
        storeService.verifyStateWithServer { result in
            handler(result.map { $0.isUnlocked })
        }
    }

    public var isAppUnlocked: Bool {
        return storeService.state.isUnlocked
    }
}
