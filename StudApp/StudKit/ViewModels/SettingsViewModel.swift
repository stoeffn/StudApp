//
//  SettingsViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 24.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class SettingsViewModel {
    private let studIpService = ServiceContainer.default[StudIpService.self]

    public init() {}

    /// Sign user out of this app and the API.
    public func signOut() {
        studIpService.signOut()
    }
}
