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

extension Organization {
    // MARK: - Updating Discovery

    func updateDiscovery(forced: Bool = false, completion: @escaping ResultHandler<ApiRoutesAvailablity>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        let updatedAt = \Organization.state.discoveryUpdatedAt
        update(lastUpdatedAt: updatedAt, expiresAfter: 60 * 10, forced: forced, completion: completion) { updaterCompletion in
            studIpService.api.requestDecoded(.discovery) { (result: Result<DiscoveryResponse>) in
                context.perform {
                    let result = result.map { try self.updateDiscovery(with: $0) }
                    updaterCompletion(result)
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
                    let result = result.map { try $0.coreDataObject(organization: self, in: context) }
                    updaterCompletion(result)
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
                    let result = result.map { try self.updateSemesters(Semester.fetchRequest(), with: $0) }
                    updaterCompletion(result)
                }
            }
        }
    }

    func updateSemesters(_ existingObjects: NSFetchRequest<Semester>, with responses: [SemesterResponse]) throws -> Set<Semester> {
        guard let context = managedObjectContext else { fatalError() }

        let semesters = try Semester.update(existingObjects, with: responses, in: context) { response in
            try response.coreDataObject(organization: self, in: context)
        }

        NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
        NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }

        return Set(semesters)
    }

    // MARK: - Checking for Feature Support

    public var supportsSettingCourseGroups: Bool {
        let route = StudIpRoutes.setGroupForCourse(withId: "", andUserWithId: "", groupId: 0)
        return routesAvailability?.supports(route: route) ?? false
    }

    public var supportsNotifications: Bool {
        return false // Disable globally for now
    }
}
