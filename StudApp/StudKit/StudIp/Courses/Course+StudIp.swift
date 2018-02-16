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
            let result = result.map { try update(fetchRequest(), with: $0, in: context) }
            handler(result)
        }
    }

    static func update(_ existingObjects: NSFetchRequest<Course>, with response: [CourseResponse],
                       in context: NSManagedObjectContext) throws -> [Course] {
        let courses = try Course.update(existingObjects, with: response, in: context) { try $0.coreDataObject(in: context) }

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
            let result = result.map { announcementResponses in
                try Announcement.update(self.announcementsFetchRequest, with: announcementResponses, in: context) { response in
                    try response.coreDataObject(in: context)
                }
            }
            handler(result)
        }
    }

    public func updateEvents(in context: NSManagedObjectContext, handler: @escaping ResultHandler<[Event]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestCollection(.eventsInCourse(withId: id)) { (result: Result<[EventResponse]>) in
            guard let course = context.object(with: self.objectID) as? Course else { fatalError() }
            let result = result.map { eventResponses in
                try Event.update(course.eventsFetchRequest, with: eventResponses, in: context) { response in
                    try response.coreDataObject(course: course, in: context)
                }
            }
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
