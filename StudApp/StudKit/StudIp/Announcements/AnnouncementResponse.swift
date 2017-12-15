//
//  AnnouncementResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 15.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

struct AnnouncementResponse: Decodable {
    let id: String
    let rawCreatedAt: String
    let rawModifiedAt: String
    let rawExpiresAfter: String
    let title: String
    let body: String

    enum CodingKeys: String, CodingKey {
        case id = "news_id"
        case rawCreatedAt = "mkdate"
        case rawModifiedAt = "chdate"
        case rawExpiresAfter = "expire"
        case title = "topic"
        case body
    }

    init(id: String, rawCreatedAt: String, rawModifiedAt: String, rawExpiresAfter: String, title: String, body: String = "") {
        self.id = id
        self.rawCreatedAt = rawCreatedAt
        self.rawModifiedAt = rawModifiedAt
        self.rawExpiresAfter = rawExpiresAfter
        self.title = title
        self.body = body
    }
}

// MARK: - Utilities

extension AnnouncementResponse {
    var createdAt: Date {
        return Date(timeIntervalSince1970: TimeInterval(rawCreatedAt)!)
    }

    var modifiedAt: Date {
        return Date(timeIntervalSince1970: TimeInterval(rawModifiedAt)!)
    }

    var expiresAt: Date {
        return createdAt + TimeInterval(rawExpiresAfter)!
    }
}
