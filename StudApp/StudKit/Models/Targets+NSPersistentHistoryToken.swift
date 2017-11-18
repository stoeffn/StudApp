//
//  Targets+NSPersistentHistoryToken.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension Targets {
    var mergedHistoryTokensUserDefaultsKey: String? {
        switch self {
        case .app: return "historyTokensMergedIntoApp"
        case .fileProvider: return "historyTokensMergedIntoFileProvider"
        default: return nil
        }
    }

    var mergedHistoryTokens: [NSPersistentHistoryToken]? {
        get {
            let storageService = ServiceContainer.default[StorageService.self]
            guard let defaults = storageService.defaults,
                let key = mergedHistoryTokensUserDefaultsKey else { return nil }
            return defaults.array(forKey: key)?
                .flatMap { $0 as? Data }
                .flatMap { NSPersistentHistoryToken.from(data: $0) }
        }
        set {
            let storageService = ServiceContainer.default[StorageService.self]
            guard let newValue = newValue,
                let defaults = storageService.defaults,
                let key = mergedHistoryTokensUserDefaultsKey else { return }
            defaults.set(newValue.map { $0.data }, forKey: key)
        }
    }
}
