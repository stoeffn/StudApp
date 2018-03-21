//
//  StudIpService.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import CoreSpotlight

public class StudIpService {
    let api: Api<StudIpRoutes>

    // MARK: - Life Cycle

    init(api: Api<StudIpRoutes>) {
        self.api = api
    }

    convenience init() {
        self.init(api: Api<StudIpRoutes>())

        guard let currentUser = User.current else { return }
        let oAuth1 = try? OAuth1<StudIpOAuth1Routes>(fromPersistedService: currentUser.objectIdentifier.rawValue)
        let apiUrl = currentUser.organization.apiUrl
        oAuth1?.baseUrl = apiUrl

        api.baseUrl = apiUrl
        api.authorizing = oAuth1
    }

    // MARK: - Authorizing

    /// Whether the user is currently signed in.
    ///
    /// - Warning: This does not garantuee that the credential is actually correct as this implementation only relies on a
    ///            credential being stored. Thus, the password might have changed in the meantime.
    public var isSignedIn: Bool {
        return api.authorizing?.isAuthorized ?? false
    }

    func sign(into organization: Organization, authorizing: ApiAuthorizing, completion: @escaping ResultHandler<User>) {
        let coreDataService = ServiceContainer.default[CoreDataService.self]
        var persistableApiAuthorizing = authorizing as? PersistableApiAuthorizing

        signOut()

        api.baseUrl = organization.apiUrl
        api.authorizing = authorizing

        let group = DispatchGroup()

        var discoveryResult: Result<ApiRoutesAvailablity>!
        group.enter()
        organization.updateDiscovery(forced: true) { result in
            discoveryResult = result
            group.leave()
        }

        var userResult: Result<User>!
        group.enter()
        organization.updateCurrentUser(forced: true) { result in
            userResult = result
            group.leave()
        }

        var semesterResult: Result<Set<Semester>>!
        group.enter()
        organization.updateSemesters(forced: true) { result in
            semesterResult = result
            group.leave()
        }

        group.notify(queue: .main) {
            guard discoveryResult.isSuccess, let user = userResult.value, semesterResult.isSuccess else {
                self.signOut()
                return completion(.failure(discoveryResult.error ?? userResult.error ?? semesterResult.error))
            }

            User.current = user
            persistableApiAuthorizing?.service = user.objectIdentifier.rawValue
            try? persistableApiAuthorizing?.persistCredentials()
            try? coreDataService.viewContext.saveAndWaitWhenChanged()

            if #available(iOSApplicationExtension 11.0, *) {
                NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            }

            completion(userResult)
        }
    }

    /// Removes the default credential used for authentication, replaces it with an empty credential, and clears the database.
    func signOut() {
        try? (api.authorizing as? PersistableApiAuthorizing)?.removeCredentials()

        api.baseUrl = nil
        api.authorizing = nil

        User.current?.organization.state.discoveryUpdatedAt = nil
        User.current?.organization.state.currentUserUpdatedAt = nil
        User.current?.organization.state.semestersUpdatedAt = nil
        User.current?.state.authoredCoursesUpdatedAt = nil
        User.current = nil

        let coreDataService = ServiceContainer.default[CoreDataService.self]
        try? coreDataService.removeAllObjects(in: coreDataService.viewContext)
        try? coreDataService.viewContext.saveAndWaitWhenChanged()

        let storageService = ServiceContainer.default[StorageService.self]
        try? storageService.removeAllDownloads()

        CSSearchableIndex.default().deleteAllSearchableItems { _ in }

        if #available(iOSApplicationExtension 11.0, *) {
            NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }
    }

    // MARK: - Updating

    func update(in context: NSManagedObjectContext, completion: @escaping () -> Void) {
        guard let user = User.current?.in(context) else { return completion() }

        let group = DispatchGroup()

        group.enter()
        user.organization.updateDiscovery { _ in group.leave() }

        group.enter()
        user.organization.updateCurrentUser { _ in group.leave() }

        group.enter()
        user.organization.updateSemesters { _ in
            defer { group.leave() }

            group.enter()
            user.updateAuthoredCourses { _ in
                group.leave()
            }
        }

        group.notify(queue: .main) { completion() }
    }

    private func updateAuthoredCoursesInVisibleSemesters(for user: User, group: DispatchGroup, context: NSManagedObjectContext) throws {
        let visibleSemesters = try user.organization.fetchVisibleSemesters(in: context)
        let visibleCourses = visibleSemesters.flatMap { $0.courses }
        let visibleAuthoredCourses = user.authoredCourses.intersection(visibleCourses)

        for course in visibleAuthoredCourses {
            group.enter()
            course.updateAnnouncements { _ in group.leave() }

            updateChildFilesRecursivly(in: course, group: group, context: context)
        }
    }

    private func updateChildFilesRecursivly(in container: FilesContaining, group: DispatchGroup, context: NSManagedObjectContext) {
        group.enter()
        container.updateChildFiles(forced: false) { _ in
            defer { group.leave() }

            let childFolders = try? container.fetchChildFolders(in: context)
            for folder in childFolders ?? [] {
                self.updateChildFilesRecursivly(in: folder, group: group, context: context)
            }
        }
    }
}
