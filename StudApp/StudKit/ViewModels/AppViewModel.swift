//
//  AppViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 10.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Manages applications main view.
public final class AppViewModel {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let studIpService = ServiceContainer.default[StudIpService.self]

    public init() {}

    /// Whether the user is currently signed in.
    public var isSignedIn: Bool {
        return studIpService.isSignedIn
    }

    public func signOut() {
        studIpService.signOut()
    }

    public func update() {
        coreDataService.performBackgroundTask { context in
            self.studIpService.update(in: context) {
                try? context.saveAndWaitWhenChanged()
            }
        }
    }
}
