//
//  User+StudIp.swift
//  StudKit
//
//  Created by Steffen Ryll on 24.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import CoreSpotlight

extension User {

    // MARK: - Updating Courses

    func updateAuthoredCourses(completion: @escaping ResultHandler<[Course]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        update(lastUpdatedAt: \.state.authoredCoursesUpdatedAt, expiresAfter: 60 * 10, completion: completion) { updaterCompletion in
            studIpService.api.requestCollection(.courses(forUserId: self.id)) { (result: Result<[CourseResponse]>) in
                context.perform {
                    let result = result.map { try self.updateAuthoredCourses(self.authoredCoursesFetchRequest(), with: $0) }
                    updaterCompletion(result)
                }
            }
        }
    }

    func updateAuthoredCourses(_ existingObjects: NSFetchRequest<Course>, with responses: [CourseResponse]) throws -> [Course] {
        guard let context = managedObjectContext else { fatalError() }

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

        return courses
    }
}
