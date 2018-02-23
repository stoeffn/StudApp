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
    public func updateChildFiles(in context: NSManagedObjectContext, completion: @escaping ResultHandler<Set<File>>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestDecoded(.rootFolderForCourse(withId: id)) { (result: Result<FolderResponse>) in
            let result = result.map { response -> Set<File> in
                guard let course = context.object(with: self.objectID) as? Course else { fatalError() }
                return try Course.updateChildFiles(from: response, course: course, in: context)
            }
            completion(result)
        }
    }

    private static func updateChildFiles(from response: FolderResponse, course: Course,
                                         in context: NSManagedObjectContext) throws -> Set<File> {
        let folders = try File.update(course.childFoldersFetchRequest, with: response.folders ?? [], in: context) { response in
            try response.coreDataObject(course: course, parent: nil, in: context)
        }
        let documents = try File.update(course.childDocumentsFetchRequest, with: response.documents ?? [], in: context) { response in
            try response.coreDataObject(course: course, parent: nil, in: context)
        }

        let searchableItems = documents.map { $0.searchableItem }
        CSSearchableIndex.default().indexSearchableItems(searchableItems) { _ in }

        if #available(iOSApplicationExtension 11.0, *) {
            let itemIdentifier = NSFileProviderItemIdentifier(rawValue: course.objectIdentifier.rawValue)
            NSFileProviderManager.default.signalEnumerator(for: itemIdentifier) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }

        return Set(folders).union(documents)
    }

    public func updateAnnouncements(in context: NSManagedObjectContext, completion: @escaping ResultHandler<[Announcement]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestCollection(.announcementsInCourse(withId: id)) { (result: Result<[AnnouncementResponse]>) in
            let result = result.map { announcementResponses -> [Announcement] in
                guard let course = context.object(with: self.objectID) as? Course else { fatalError() }
                return try Announcement.update(self.announcementsFetchRequest, with: announcementResponses, in: context) { response in
                    try response.coreDataObject(organization: course.organization, in: context)
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
