//
//  Course+StudIp.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import CoreSpotlight
import FileProvider

extension Course {
    public static func update(in context: NSManagedObjectContext, handler: @escaping ResultHandler<[Course]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let userId = studIpService.userId else { return }

        studIpService.api.requestCollection(.courses(forUserId: userId)) { (result: Result<[CourseResponse]>) in
            let result = result.map { try updateCourses(from: $0, in: context) }
            let group = DispatchGroup()
            var error = result.error

            result.value?.forEach { course in
                group.enter()

                studIpService.api.requestDecoded(.rootFolderForCourse(withId: course.id)) { (result: Result<FolderResponse>) in
                    let result = result.map { try File.updateFolder(from: $0, in: context) }
                    result.value?.name = course.title // Make sure the root folder has the same name as the course and is not empty.
                    course.rootFolder = result.value ?? course.rootFolder

                    error = result.error
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                if let error = error {
                    handler(.failure(error))
                } else {
                    handler(result)
                }
            }
        }
    }

    static func updateCourses(from response: [CourseResponse], in context: NSManagedObjectContext) throws -> [Course] {
        let courses = try Course.update(using: response, in: context)

        CSSearchableIndex.default().indexSearchableItems(courses.map { $0.searchableItem }) { _ in }

        try? Semester.fetchNonHidden(in: context).forEach { semester in
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

    public func updateAnnouncements(in context: NSManagedObjectContext, handler: @escaping ResultHandler<[Announcement]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestCollection(.announcementsInCourse(withId: id)) { (result: Result<[AnnouncementResponse]>) in
            handler(result.map { try Announcement.update(using: $0, in: context) })
        }
    }

    public func updateEvents(in context: NSManagedObjectContext, handler: @escaping ResultHandler<[Event]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestCollection(.eventsInCourse(withId: id)) { (result: Result<[EventResponse]>) in
            guard let course = context.object(with: self.objectID) as? Course else { fatalError() }
            let result = result.map { try Event.update(using: $0, in: context) }
            result.value?.forEach { $0.course = course }
            handler(result)
        }
    }

    public var url: URL? {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard
            let baseUrl = studIpService.api.baseUrl?.deletingLastPathComponent(),
            let url = URL(string: "\(baseUrl)/dispatch.php/course/overview?cid=\(id)")
        else { return nil }
        return url
    }
}
