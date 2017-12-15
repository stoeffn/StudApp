//
//  AnnouncementResponse+CDConvertible.swift
//  StudKit
//
//  Created by Steffen Ryll on 15.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension AnnouncementResponse: CDConvertible {
    func coreDataModel(in context: NSManagedObjectContext) throws -> NSManagedObject {
        guard
            let createdAt = createdAt,
            let modifiedAt = modifiedAt,
            let expiresAt = expiresAt
        else { throw "Cannot create announcement without creation or modification date." }

        let courses = try Course.fetch(byIds: courseIds, in: context).set

        let (announcement, _) = try Announcement.fetch(byId: id, orCreateIn: context)
        announcement.id = id
        announcement.courses = courses
        announcement.createdAt = createdAt
        announcement.modifiedAt = modifiedAt
        announcement.expiresAt = expiresAt
        announcement.title = title
        announcement.body = body
        return announcement
    }
}
