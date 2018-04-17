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

extension User {

    // MARK: - Updating Courses

    func updateAuthoredCourses(forced: Bool = false, completion: @escaping ResultHandler<Set<Course>>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        let updatedAt = \User.state.authoredCoursesUpdatedAt
        update(lastUpdatedAt: updatedAt, expiresAfter: 60 * 10, forced: forced, completion: completion) { updaterCompletion in
            studIpService.api.requestCollection(.courses(forUserId: self.id)) { (result: Result<[CourseResponse]>) in
                context.perform {
                    let result = result.map { try self.updateAuthoredCourses(self.authoredCoursesFetchRequest(), with: $0) }
                    updaterCompletion(result)
                }
            }
        }
    }

    func updateAuthoredCourses(_ existingObjects: NSFetchRequest<Course>, with responses: [CourseResponse]) throws -> Set<Course> {
        guard let context = managedObjectContext else { fatalError() }

        // TODO: Reset relationship instead of deleting in order to provide multi-user support.
        let courses = try Course.update(existingObjects, with: responses, in: context) { response in
            try response.coreDataObject(organization: organization, author: self, in: context)
        }

        CSSearchableIndex.default().indexSearchableItems(courses.map { $0.searchableItem }) { _ in }

        if #available(iOSApplicationExtension 11.0, *) {
            NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }

            for semester in try organization.fetchVisibleSemesters(in: context) {
                let itemidentifier = NSFileProviderItemIdentifier(rawValue: semester.objectIdentifier.rawValue)
                NSFileProviderManager.default.signalEnumerator(for: itemidentifier) { _ in }
            }
        }

        return Set(courses)
    }

    // MARK: - Updating Events

    public func updateEvents(forced: Bool = false, completion: @escaping ResultHandler<Set<Event>>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        let updatedAt = \User.state.eventsUpdatedAt
        update(lastUpdatedAt: updatedAt, expiresAfter: 60 * 10, forced: forced, completion: completion) { updaterCompletion in
            studIpService.api.requestCollection(.eventsForUser(withId: self.id)) { (result: Result<[EventResponse]>) in
                context.perform {
                    let result = result.map { responses in
                        // TODO: Reset relationship instead of deleting in order to provide multi-user support.
                        try Event.update(self.eventsFetchRequest, with: responses, in: context) { response in
                            try response.coreDataObject(user: self.in(context), in: context)
                        }
                    }.map(Set.init)
                    updaterCompletion(result)
                }
            }
        }
    }
}
