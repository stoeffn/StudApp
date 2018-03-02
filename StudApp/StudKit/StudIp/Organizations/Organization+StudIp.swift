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

    func updateDiscovery(completion: @escaping ResultHandler<ApiRoutesAvailablity>) {
        update(lastUpdatedAt: \.state.discoveryUpdatedAt, expiresAfter: 60 * 10, completion: completion) { updaterCompletion in
            let studIpService = ServiceContainer.default[StudIpService.self]
            studIpService.api.requestDecoded(.discovery) { (result: Result<DiscoveryResponse>) in
                updaterCompletion(result.map { try self.updateDiscovery(with: $0) })
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

    func updateCurrentUser(completion: @escaping ResultHandler<User>) {
        update(lastUpdatedAt: \.state.currentUserUpdatedAt, expiresAfter: 60 * 10, completion: completion) { updaterCompletion in
            let studIpService = ServiceContainer.default[StudIpService.self]
            studIpService.api.requestDecoded(.currentUser) { (result: Result<UserResponse>) in
                guard let context = self.managedObjectContext else { fatalError() }
                updaterCompletion(result.map { try $0.coreDataObject(organization: self, in: context) })
            }
        }
    }

    // MARK: - Updating Semesters

    func updateSemesters(completion: @escaping ResultHandler<Set<Semester>>) {
        update(lastUpdatedAt: \.state.semestersUpdatedAt, expiresAfter: 60 * 10, completion: completion) { updaterCompletion in
            let studIpService = ServiceContainer.default[StudIpService.self]
            studIpService.api.requestCollection(.semesters) { (result: Result<[SemesterResponse]>) in
                updaterCompletion(result.map { try self.updateSemesters(Semester.fetchRequest(), with: $0) })
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
