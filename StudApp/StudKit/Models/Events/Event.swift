//
//  Event.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(Event)
public final class Event: NSManagedObject, CDCreatable, CDIdentifiable, CDSortable {

    // MARK: Identification

    public static var entity = ObjectIdentifier.Entites.event

    @NSManaged public var id: String

    // MARK: Managing Timing

    @NSManaged public var startsAt: Date

    @NSManaged public var endsAt: Date

    @NSManaged public var isCanceled: Bool

    @NSManaged public var cancellationReason: String?

    // MARK: Specifying Location

    @NSManaged public var location: String?

    @NSManaged public var course: Course

    // MARK: Managing Metadata

    @NSManaged public var summary: String?

    @NSManaged public var category: String?

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \Event.startsAt, ascending: true),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<Event id: \(id), course: \(course.id)>"
    }
}

// MARK: - Utilities

extension Event {
    @objc var daysSince1970: Int {
        return startsAt.days(since: Date(timeIntervalSince1970: 0))
    }
}
