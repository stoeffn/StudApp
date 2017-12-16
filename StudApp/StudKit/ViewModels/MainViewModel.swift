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

    public func verifyStoreState(handler: @escaping ResultHandler<Routes?>) {
        storeService.verifyStateWithServer { result in
            guard let state = result.value else { return handler(result.replacingValue(nil)) }
            let route = !state.isUnlocked ? Routes.store : nil
            handler(result.replacingValue(route))
        }
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

    public var routeToPerformOnAppStart: Routes? {
        guard studIpService.isSignedIn else { return .signIn }
        guard storeService.state.isUnlocked else { return .verification }
        return nil
    }
}
