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
    public static func update(in context: NSManagedObjectContext, completion: @escaping ResultHandler<[Course]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let userId = studIpService.userId else { return }

        studIpService.api.requestCollection(.courses(forUserId: userId)) { (result: Result<[CourseResponse]>) in
            let result = result.map { try update(fetchRequest(), with: $0, in: context) }
            completion(result)
        }
    }

    static func update(_ existingObjects: NSFetchRequest<Course>, with response: [CourseResponse],
                       in context: NSManagedObjectContext) throws -> [Course] {
        let courses = try Course.update(existingObjects, with: response, in: context) { try $0.coreDataObject(in: context) }

        CSSearchableIndex.default().indexSearchableItems(courses.map { $0.searchableItem }) { _ in }

        try? Semester.fetchVisibleStates(in: context).forEach { semester in
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

    public func updateChildFiles(in context: NSManagedObjectContext, completion: @escaping ResultHandler<File>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestDecoded(.rootFolderForCourse(withId: id)) { (result: Result<FolderResponse>) in
            let result = result.map { response -> File in
                guard let course = context.object(with: self.objectID) as? Course else { fatalError() }
                let folder = try File.updateFolder(from: response, course: course, in: context)

                // Set each of the child files' parents to `nil`, making them root files themselves and delete the original
                // root folder afterwards. The order is important this is a cascading relationship. All this is to make all
                // files in a course's root folder appear at the root level instead of nested inside an folder with the same
                // name as the course, which would be redundant.
                folder.children.forEach { $0.parent = nil }
                context.delete(folder)

                return folder
            }
            completion(result)
        }
    }

    public func updateAnnouncements(in context: NSManagedObjectContext, completion: @escaping ResultHandler<[Announcement]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestCollection(.announcementsInCourse(withId: id)) { (result: Result<[AnnouncementResponse]>) in
            let result = result.map { announcementResponses in
                try Announcement.update(self.announcementsFetchRequest, with: announcementResponses, in: context) { response in
                    try response.coreDataObject(in: context)
                }
            }
            completion(result)
        }
    }

    public func updateEvents(in context: NSManagedObjectContext, completion: @escaping ResultHandler<[Event]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestCollection(.eventsInCourse(withId: id)) { (result: Result<[EventResponse]>) in
            let result = result.map { eventResponses -> [Event] in
                guard let course = context.object(with: self.objectID) as? Course else { fatalError() }
                return try Event.update(course.eventsFetchRequest, with: eventResponses, in: context) { response in
                    try response.coreDataObject(course: course, in: context)
                }
            }
            completion(result)
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
