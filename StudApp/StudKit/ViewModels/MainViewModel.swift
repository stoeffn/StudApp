//
//  MainViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 10.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Manages applications main view.
public final class MainViewModel {
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

    /// Sign user out of this app and the API.
    public func signOut() {
        studIpService.signOut()
    }

    /// Updates the current user if signed in.
    public func updateCurrentUser(handler: (ResultHandler<User>)? = nil) {
        User.updateCurrent(in: coreDataService.viewContext) { result in
            try? self.coreDataService.viewContext.saveWhenChanged()
            handler?(result)
        }
    }

    /// Currently signed in user. This property performs a fetch every time it is accessed.
    public var currentUser: User? {
        guard let user = try? User.fetchCurrent(in: coreDataService.viewContext) else { return nil }
        return user
    }

    public var isAppLocked: Bool {
        return storeService.state.isLocked
    }
}
