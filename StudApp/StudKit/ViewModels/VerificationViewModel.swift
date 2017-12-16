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

    public func verifyStoreState(handler: @escaping ResultHandler<Routes?>) {
        storeService.verifyStateWithServer { result in
            guard let state = result.value else { return handler(result.replacingValue(nil)) }
            let route = !state.isUnlocked ? Routes.store : nil
            handler(result.replacingValue(route))
        }
    }
}
