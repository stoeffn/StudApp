//
//  EventResponse+CDConvertible.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension EventResponse: CDConvertible {
    @discardableResult
    func coreDataModel(in context: NSManagedObjectContext) throws -> NSManagedObject {
        let (event, _) = try Event.fetch(byId: id, orCreateIn: context)
        event.id = id
        event.startsAt = startsAt
        event.endsAt = endsAt
        event.isCanceled = isCanceled
        event.cancellationReason = cancellationReason
        event.location = location
        event.summary = summary
        event.category = category
        return event
    }
}
