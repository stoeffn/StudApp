//
//  AnnouncementResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 15.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

struct AnnouncementResponse: Decodable {
    let id: String
    private let coursePaths: [String]
    private let rawCreatedAt: String
    private let rawModifiedAt: String
    private let rawExpiresAfter: String
    let title: String
    let body: String

    enum CodingKeys: String, CodingKey {
        case id = "news_id"
        case coursePaths = "ranges"
        case rawCreatedAt = "mkdate"
        case rawModifiedAt = "chdate"
        case rawExpiresAfter = "expire"
        case title = "topic"
        case body
    }

    init(id: String, coursePaths: [String] = [], rawCreatedAt: String, rawModifiedAt: String, rawExpiresAfter: String,
         title: String, body: String = "") {
        self.id = id
        self.coursePaths = coursePaths
        self.rawCreatedAt = rawCreatedAt
        self.rawModifiedAt = rawModifiedAt
        self.rawExpiresAfter = rawExpiresAfter
        self.title = title
        self.body = body
    }
}

// MARK: - Utilities

extension AnnouncementResponse {
    var createdAt: Date? {
        guard let interval = TimeInterval(rawCreatedAt) else { return nil }
        return Date(timeIntervalSince1970: interval)
    }

    var modifiedAt: Date? {
        guard let interval = TimeInterval(rawModifiedAt) else { return nil }
        return Date(timeIntervalSince1970: interval)
    }

    var expiresAt: Date? {
        guard let createdAt = createdAt else { return nil }
        return createdAt + TimeInterval(rawExpiresAfter)!
    }

    var courseIds: [String] {
        return coursePaths.flatMap {StudIp.transformIdPath($0, idComponentIndex: 2) }
    }
}
