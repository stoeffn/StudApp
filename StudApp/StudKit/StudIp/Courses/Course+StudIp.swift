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

    // MARK: - Updating Files

    public func updateChildFiles(completion: @escaping ResultHandler<Set<File>>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        update(lastUpdatedAt: \.state.childFilesUpdatedAt, expiresAfter: 60 * 10, completion: completion) { updaterCompletion in
            context.perform {
                studIpService.api.requestDecoded(.rootFolderForCourse(withId: self.id)) { (result: Result<FolderResponse>) in
                    updaterCompletion(result.map { try self.updateChildFiles(from: $0) })
                }
            }
        }
    }

    func updateChildFiles(from response: FolderResponse) throws -> Set<File> {
        guard let context = managedObjectContext else { fatalError() }

        let folders = try File.update(childFoldersFetchRequest, with: response.folders ?? [], in: context) { response in
            try response.coreDataObject(course: self, parent: nil, in: context)
        }
        let documents = try File.update(childDocumentsFetchRequest, with: response.documents ?? [], in: context) { response in
            try response.coreDataObject(course: self, parent: nil, in: context)
        }

        CSSearchableIndex.default().indexSearchableItems(documents.map { $0.searchableItem }) { _ in }

        if #available(iOSApplicationExtension 11.0, *) {
            let itemIdentifier = NSFileProviderItemIdentifier(rawValue: objectIdentifier.rawValue)
            NSFileProviderManager.default.signalEnumerator(for: itemIdentifier) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }

        return Set(folders).union(documents)
    }

    // MARK: - Updating Announcements

    public func updateAnnouncements(completion: @escaping ResultHandler<Set<Announcement>>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        update(lastUpdatedAt: \.state.announcementsUpdatedAt, expiresAfter: 60 * 10, completion: completion) { updaterCompletion in
            studIpService.api.requestCollection(.announcementsInCourse(withId: self.id)) { (result: Result<[AnnouncementResponse]>) in
                context.perform {
                    updaterCompletion(result.map { try self.updateAnnouncements(from: $0) })
                }
            }
        }
    }

    func updateAnnouncements(from responses: [AnnouncementResponse]) throws -> Set<Announcement> {
        guard let context = managedObjectContext else { fatalError() }

        let announcements = try Announcement.update(announcementsFetchRequest, with: responses, in: context) { response in
            try response.coreDataObject(organization: self.organization, in: context)
        }

        return Set(announcements)
    }

    // MARK: - Updating Events

    public func updateEvents(completion: @escaping ResultHandler<Set<Event>>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        update(lastUpdatedAt: \.state.eventsUpdatedAt, expiresAfter: 60 * 10, completion: completion) { updaterCompletion in
            studIpService.api.requestCollection(.eventsInCourse(withId: self.id)) { (result: Result<[EventResponse]>) in
                context.perform {
                    updaterCompletion(result.map { try self.updateEvents(from: $0) })
                }
            }
        }
    }

    func updateEvents(from responses: [EventResponse]) throws -> Set<Event> {
        guard let context = managedObjectContext else { fatalError() }

        let events = try Event.update(eventsFetchRequest, with: responses, in: context) { response in
            try response.coreDataObject(course: self, in: context)
        }

        return Set(events)
    }

    // MARK: - Setting Properties

    public func set(groupId: Int, for user: User, completion: @escaping ResultHandler<Void>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        studIpService.api.request(.setGroupForCourse(withId: id, andUserWithId: user.id, groupId: groupId)) { result in
            guard result.isSuccess else { return completion(.failure(result.error)) }

            context.perform {
                self.groupId = groupId
                completion(result.map { _ in })
            }
        }
    }

    // MARK: - Managing Metadata

    public var url: URL? {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard
            let baseUrl = studIpService.api.baseUrl?.deletingLastPathComponent(),
            let url = URL(string: "\(baseUrl)/dispatch.php/course/overview?cid=\(id)")
        else { return nil }
        return url
    }
}
