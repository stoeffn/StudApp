//
//  DefaultsKeys+HistoryService.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension DefaultsKeys {
    static let mergedAppHistoryTokens = DefaultsKey<[Data]>(Targets.app.rawValue)
    static let mergedFileProviderHistoryTokens = DefaultsKey<[Data]>(Targets.fileProvider.rawValue)
}

// MARK: Targets Utilities

extension Targets {
    var mergedHistoryTokensUserDefaultsKey: DefaultsKey<[Data]>? {
        switch self {
        case .app: return DefaultsKeys.mergedAppHistoryTokens
        case .fileProvider: return DefaultsKeys.mergedFileProviderHistoryTokens
        default: return nil
        }
    }

    var mergedHistoryTokens: [NSPersistentHistoryToken]? {
        get {
            guard let key = mergedHistoryTokensUserDefaultsKey else { return nil }
            return Defaults[key].flatMap { NSPersistentHistoryToken.from(data: $0) }
        }
        set {
            guard let newValue = newValue, let key = mergedHistoryTokensUserDefaultsKey else { return }
            Defaults[key] = newValue.map { $0.data }
        }
    }
}
