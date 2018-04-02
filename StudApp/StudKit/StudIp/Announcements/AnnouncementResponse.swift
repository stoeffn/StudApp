//
//  AnnouncementResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 15.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

struct AnnouncementResponse: IdentifiableResponse {
    let id: String
    let courseIds: Set<String>
    let userId: String?
    let createdAt: Date
    let modifiedAt: Date
    let expiresAfter: TimeInterval
    let expiresAt: Date
    let title: String
    let htmlContent: String
    let textContent: String

    init(id: String, courseIds: Set<String> = [], userId: String? = nil, createdAt: Date = .distantPast,
         modifiedAt: Date = .distantPast, expiresAfter: TimeInterval = 0, title: String = "",
         htmlContent: String = "", textContent: String = "") {
        self.id = id
        self.courseIds = courseIds
        self.userId = userId
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.expiresAfter = expiresAfter
        expiresAt = createdAt + expiresAfter
        self.title = title
        self.htmlContent = htmlContent
        self.textContent = textContent
    }
}

// MARK: - Coding

extension AnnouncementResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "news_id"
        case courseIds = "ranges"
        case userId = "user_id"
        case createdAt = "mkdate"
        case modifiedAt = "chdate"
        case expiresAfter = "expire"
        case title = "topic"
        case htmlContent = "body_html"
        case textContent = "body"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawCourseIds = try container.decode(Set<String>.self, forKey: .courseIds)
        id = try container.decode(String.self, forKey: .id)
        courseIds = Set(rawCourseIds.compactMap { StudIp.transform(idPath: $0) })
        userId = try container.decodeIfPresent(String.self, forKey: .userId)?.nilWhenEmpty
        createdAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .createdAt)
        modifiedAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .modifiedAt)
        expiresAfter = TimeInterval(try container.decode(String.self, forKey: .expiresAfter)) ?? 0
        expiresAt = createdAt + expiresAfter
        title = try container.decode(String.self, forKey: .title)
        htmlContent = try container.decode(String.self, forKey: .htmlContent)
        textContent = try container.decode(String.self, forKey: .textContent)
    }
}

// MARK: - Converting to a Core Data Object

extension AnnouncementResponse {
    @discardableResult
    func coreDataObject(organization: Organization, in context: NSManagedObjectContext) throws -> Announcement {
        let (announcement, _) = try Announcement.fetch(byId: id, orCreateIn: context)
        let courses = try Course.fetch(byIds: courseIds, in: context)
        announcement.organization = organization
        announcement.courses = Set(courses)
        announcement.user = try User.fetch(byId: userId, in: context)
        announcement.createdAt = createdAt
        announcement.modifiedAt = modifiedAt
        announcement.expiresAt = expiresAt
        announcement.title = title
        announcement.htmlContent = htmlContent
        announcement.textContent = textContent
        return announcement
    }
}
