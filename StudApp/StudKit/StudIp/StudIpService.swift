//
//  StudIpService.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class StudIpService {
    let api: Api<StudIpRoutes>

    init(baseUrl: URL, realm: String) {
        api = Api<StudIpRoutes>(baseUrl: baseUrl, realm: realm)
    }

    init(api: Api<StudIpRoutes>) {
        self.api = api
    }

    /// Whether the user is currently signed in.
    ///
    /// - Warning: This does not garantuee that the credential is actually correct as this implementation only relies on a
    ///            credential being stored. Thus, the password might have changed in the meantime.
    public var isSignedIn: Bool {
        guard let credential = URLCredentialStorage.shared.defaultCredential(for: api.protectionSpace) else { return false }
        return !(credential.user?.isEmpty ?? true)
    }

    var currentUserId: String? {
        get {
            let storageService = ServiceContainer.default[StorageService.self]
            return storageService.defaults.string(forKey: UserDefaults.currentUserIdKey)
        }
        set {
            let storageService = ServiceContainer.default[StorageService.self]
            storageService.defaults.set(newValue, forKey: UserDefaults.currentUserIdKey)
        }
    }

    /// Tries to sign into Stud.IP using the credentials provided.
    ///
    /// ## How it works
    ///  0. Remove current default credential if set.
    ///  1. Create a new session credential with the provided username and password and save it as the default.
    ///  2. Request the password-protected discovery route, which provides information on available routes.
    ///  3. Remove session credential.
    ///  4. Abort if credential was rejected or another error occured during the request.
    ///  5. Create a permanent credential from the now validated username and password and save it as the default.
    ///  6. Fetch the current user from the API and mark as the current user.
    ///
    /// - Parameters:
    ///   - username: Stud.IP username.
    ///   - password: Stud.IP password.
    ///   - handler: Completion handler that is called after *every* step finished.
    func signIn(withUsername username: String, password: String, handler: @escaping ResultHandler<User>) {
        let protectionSpace = api.protectionSpace

        if let credential = URLCredentialStorage.shared.defaultCredential(for: protectionSpace) {
            URLCredentialStorage.shared.remove(credential, for: protectionSpace)
        }

        let credential = URLCredential(user: username, password: password, persistence: .forSession)
        URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)

        api.request(.discovery) { result in
            URLCredentialStorage.shared.remove(credential, for: protectionSpace)

            guard result.isSuccess else { return handler(result.replacingValue(nil)) }

            let validatedCredential = URLCredential(user: username, password: password, persistence: .synchronizable)
            URLCredentialStorage.shared.setDefaultCredential(validatedCredential, for: protectionSpace)

            let coreDataService = ServiceContainer.default[CoreDataService.self]
            User.updateCurrent(in: coreDataService.viewContext) { result in
                handler(result.replacingValue(result.value))
            }
        }
    }

    /// Removes the default credential used for authentication, replaces it with an empty credential, and clears the data base.
    func signOut() {
        let protectionSpace = api.protectionSpace

        guard let credential = URLCredentialStorage.shared.defaultCredential(for: protectionSpace) else { return }
        URLCredentialStorage.shared.remove(credential, for: protectionSpace)

        let emptyCredential = URLCredential(user: "", password: "", persistence: .synchronizable)
        URLCredentialStorage.shared.setDefaultCredential(emptyCredential, for: protectionSpace)

        api.removeLastRouteAccesses()

        let coreDataService = ServiceContainer.default[CoreDataService.self]
        try? coreDataService.removeAllObjects(in: coreDataService.viewContext)

        let storageService = ServiceContainer.default[StorageService.self]
        try? storageService.removeAllDocuments()

        NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
        NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
    }
}
