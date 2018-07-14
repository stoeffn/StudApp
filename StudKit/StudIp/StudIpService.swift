//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
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

        updateMainData(organization: organization) { result in
            guard let user = result.value else {
                self.signOut()
                return completion(result)
            }

            User.current = user
            persistableApiAuthorizing?.service = user.objectIdentifier.rawValue
            try? persistableApiAuthorizing?.persistCredentials()
            try? coreDataService.viewContext.saveAndWaitWhenChanged()

            if #available(iOSApplicationExtension 11.0, *) {
                NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            }

            completion(result)
        }
    }

    /// Removes the default credential used for authentication, replaces it with an empty credential, and clears the database.
    func signOut() {
        ServiceContainer.default[NotificationService.self].deleteHooks()

        try? (api.authorizing as? PersistableApiAuthorizing)?.removeCredentials()

        api.session.configuration.httpCookieStorage?.removeCookies(since: .distantPast)
        api.baseUrl = nil
        api.authorizing = nil

        User.current?.organization.state.discoveryUpdatedAt = nil
        User.current?.organization.state.currentUserUpdatedAt = nil
        User.current?.organization.state.semestersUpdatedAt = nil
        User.current?.state.authoredCoursesUpdatedAt = nil
        User.current = nil

        let coreDataService = ServiceContainer.default[CoreDataService.self]
        try? coreDataService.removeAll(of: [Semester.self, Course.self, User.self], in: coreDataService.viewContext)
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

    func updateMainData(organization: Organization, forced: Bool = false, completion: @escaping ResultHandler<User>) {
        let group = DispatchGroup()
        var discoveryResult: Result<ApiRoutesAvailablity>!
        var userResult: Result<User>!
        var semesterResult: Result<Set<Semester>>!
        var coursesResult: Result<Set<Course>>?

        group.enter()
        organization.updateDiscovery(forced: forced) { result in
            discoveryResult = result
            group.leave()
        }

        group.enter()
        organization.updateCurrentUser(forced: forced) { result in
            userResult = result

            organization.updateSemesters(forced: forced) { result in
                semesterResult = result

                guard let user = userResult.value else { return group.leave() }

                user.updateAuthoredCourses(forced: forced) { result in
                    coursesResult = result
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            let error = discoveryResult.error ?? userResult.error ?? semesterResult.error ?? coursesResult?.error
            let result = Result(userResult.value, error: error)
            completion(result)

            ServiceContainer.default[NotificationService.self].updateOrCreateHooks()
        }
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
