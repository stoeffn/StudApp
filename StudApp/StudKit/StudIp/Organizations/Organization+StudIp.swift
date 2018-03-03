//
//  Organization+StudIp.swift
//  StudKit
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension Organization {

    // MARK: - Updating Discovery

    func updateDiscovery(forced: Bool = false, completion: @escaping ResultHandler<ApiRoutesAvailablity>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        let updatedAt = \Organization.state.discoveryUpdatedAt
        update(lastUpdatedAt: updatedAt, expiresAfter: 60 * 10, forced: forced, completion: completion) { updaterCompletion in
            studIpService.api.requestDecoded(.discovery) { (result: Result<DiscoveryResponse>) in
                context.perform {
                    updaterCompletion(result.map { try self.updateDiscovery(with: $0) })
                }
            }
        }
    }

    func updateDiscovery(with response: DiscoveryResponse) throws -> ApiRoutesAvailablity {
        let routesAvailability = ApiRoutesAvailablity(from: response)
        let encoder = ServiceContainer.default[JSONEncoder.self]
        routesAvailabilityData = try encoder.encode(routesAvailability)
        return routesAvailability
    }

    // MARK: - Updating Users

    func updateCurrentUser(forced: Bool = false, completion: @escaping ResultHandler<User>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        let updatedAt = \Organization.state.currentUserUpdatedAt
        update(lastUpdatedAt: updatedAt, expiresAfter: 60 * 10, forced: forced, completion: completion) { updaterCompletion in
            studIpService.api.requestDecoded(.currentUser) { (result: Result<UserResponse>) in
                context.perform {
                    updaterCompletion(result.map { try $0.coreDataObject(organization: self, in: context) })
                }
            }
        }
    }

    // MARK: - Updating Semesters

    func updateSemesters(forced: Bool = false, completion: @escaping ResultHandler<Set<Semester>>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        let updatedAt = \Organization.state.semestersUpdatedAt
        update(lastUpdatedAt: updatedAt, expiresAfter: 60 * 10, forced: forced, completion: completion) { updaterCompletion in
            studIpService.api.requestCollection(.semesters) { (result: Result<[SemesterResponse]>) in
                context.perform {
                    updaterCompletion(result.map { try self.updateSemesters(Semester.fetchRequest(), with: $0) })
                }
            }
        }
    }

    func updateSemesters(_ existingObjects: NSFetchRequest<Semester>, with responses: [SemesterResponse]) throws -> Set<Semester> {
        guard let context = managedObjectContext else { fatalError() }

        let semesters = try Semester.update(existingObjects, with: responses, in: context) { response in
            try response.coreDataObject(organization: self, in: context)
        }

        if #available(iOSApplicationExtension 11.0, *) {
            NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }

        return Set(semesters)
    }

    // MARK: - Checking for Feature Support

    public var supportsSettingCourseGroups: Bool {
        let route = StudIpRoutes.setGroupForCourse(withId: "", andUserWithId: "", groupId: 0)
        return routesAvailability?.supports(route: route) ?? false
    }
}
