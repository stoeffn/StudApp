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
import FileProvider

extension Course {
    // MARK: - Updating Files

    public func updateChildFiles(forced: Bool = false, completion: @escaping ResultHandler<Set<File>>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        let updatedAt = \Course.state.childFilesUpdatedAt
        update(lastUpdatedAt: updatedAt, expiresAfter: 60 * 10, forced: forced, completion: completion) { updaterCompletion in
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

    public func updateAnnouncements(forced: Bool = false, completion: @escaping ResultHandler<Set<Announcement>>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        let updatedAt = \Course.state.announcementsUpdatedAt
        update(lastUpdatedAt: updatedAt, expiresAfter: 60 * 10, forced: forced, completion: completion) { updaterCompletion in
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

    public func updateEvents(forced: Bool = false, completion: @escaping ResultHandler<Set<Event>>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        let updatedAt = \Course.state.eventsUpdatedAt
        update(lastUpdatedAt: updatedAt, expiresAfter: 60 * 10, forced: forced, completion: completion) { updaterCompletion in
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
                self.groupId = Int64(groupId)
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
