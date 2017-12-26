//
//  EventResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

struct EventResponse: Decodable {
    let id: String
    private let rawStartsAt: String
    private let rawEndsAt: String
    let isCanceled: Bool
    let cancellationReason: String?
    private let rawLocation: String?
    private let rawSummary: String?
    let category: String?

    enum CodingKeys: String, CodingKey {
        case id = "event_id"
        case rawStartsAt = "start"
        case rawEndsAt = "end"
        case isCanceled = "deleted"
        case cancellationReason = "canceled"
        case rawLocation = "location"
        case rawSummary = "description"
        case category = "category"
    }

    init(id: String, rawStartsAt: String, rawEndsAt: String, isCanceled: Bool = false, cancellationReason: String? = nil,
         rawLocation: String? = nil, rawSummary: String? = nil, category: String? = nil) {
        self.id = id
        self.rawStartsAt = rawStartsAt
        self.rawEndsAt = rawEndsAt
        self.isCanceled = isCanceled
        self.cancellationReason = cancellationReason
        self.rawLocation = rawLocation
        self.rawSummary = rawSummary
        self.category = category
    }
}

// MARK: - Utilities

extension EventResponse {
    var startsAt: Date? {
        guard let interval = TimeInterval(rawStartsAt) else { return nil }
        return Date(timeIntervalSince1970: interval)
    }

    var endsAt: Date? {
        guard let interval = TimeInterval(rawEndsAt) else { return nil }
        return Date(timeIntervalSince1970: interval)
    }

    var location: String? {
        return rawLocation?.nilWhenEmpty
    }

    var summary: String? {
        return rawLocation?.nilWhenEmpty
    }
}
