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
    private let storeService = ServiceContainer.default[StoreService.self]
    private let studIpService = ServiceContainer.default[StudIpService.self]

    public init() {}

    /// Whether the user is currently signed in.
    ///
    /// - Warning: This does not garantuee that the credential is actually correct as this implementation only relies on a
    ///            credential being stored. Thus, the password might have changed in the meantime.
    public var isSignedIn: Bool {
        return studIpService.isSignedIn
    }

    /// Updates the current user if signed in.
    public func updateCurrentUser(completion: (ResultHandler<User>)? = nil) {
        guard let currentUser = User.current else { return }

        User.updateCurrent(organization: currentUser.organization, in: coreDataService.viewContext) { result in
            try? self.coreDataService.viewContext.saveAndWaitWhenChanged()
            completion?(result)
        }
    }

    public func signOut() {
        studIpService.signOut()
    }
}
