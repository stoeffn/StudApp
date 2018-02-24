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
    static func updateCurrent(organization: Organization, in context: NSManagedObjectContext,
                              completion: @escaping ResultHandler<User>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestDecoded(.currentUser) { (result: Result<UserResponse>) in
            let result = result.map { try $0.coreDataObject(organization: organization, in: context) }
            completion(result)
        }
    }

    func updateAuthoredCourses(in context: NSManagedObjectContext, completion: @escaping ResultHandler<[Course]>) {
        guard let currentId = User.current?.id else { return }

        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestCollection(.courses(forUserId: currentId)) { (result: Result<[CourseResponse]>) in
            let result = result.map { response -> [Course] in
                guard let user = context.object(with: self.objectID) as? User else { fatalError() }
                return try self.updateAuthoredCourses(user.authoredCoursesFetchRequest(), with: response, user: user, in: context)
            }
            completion(result)
        }
    }

    private func updateAuthoredCourses(_ existingObjects: NSFetchRequest<Course>, with response: [CourseResponse],
                                       user: User, in context: NSManagedObjectContext) throws -> [Course] {
        let courses = try Course.update(existingObjects, with: response, in: context) {
            try $0.coreDataObject(organization: user.organization, author: user, in: context)
        }

        CSSearchableIndex.default().indexSearchableItems(courses.map { $0.searchableItem }) { _ in }

        try? organization.fetchVisibleSemesters(in: context).forEach { semester in
            semester.state.areCoursesFetchedFromRemote = true

            if #available(iOSApplicationExtension 11.0, *) {
                let itemidentifier = NSFileProviderItemIdentifier(rawValue: semester.objectIdentifier.rawValue)
                NSFileProviderManager.default.signalEnumerator(for: itemidentifier) { _ in }
            }
        }

        if #available(iOSApplicationExtension 11.0, *) {
            NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }

        return courses
    }
}
