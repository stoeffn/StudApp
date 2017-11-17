//
//  DefaultsKeys+HistoryService.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

extension DefaultsKeys {
    static let currentAppHistoryToken = DefaultsKey<Data>(Targets.app.rawValue)
    static let currentFileProviderHistoryToken = DefaultsKey<Data>(Targets.fileProvider.rawValue)
}

// MARK: Targets Utilities

extension Targets {
    var currentHistoryTokenUserDefaultsKey: DefaultsKey<Data>? {
        switch self {
        case .app: return DefaultsKeys.currentAppHistoryToken
        case .fileProvider: return DefaultsKeys.currentFileProviderHistoryToken
        default: return nil
        }
    }
}
