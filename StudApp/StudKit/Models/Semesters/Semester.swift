//
//  Semester.swift
//  StudKit
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(Semester)
public final class Semester: NSManagedObject, CDCreatable, CDIdentifiable, CDSortable {

    // MARK: Identifications

    public static let entity = ObjectIdentifier.Entites.semester

    @NSManaged public var id: String

    @NSManaged public var title: String

    // MARK: Specifying Location

    @NSManaged public var organization: Organization

    @NSManaged public var courses: Set<Course>

    // MARK: Managing Timing

    @NSManaged public var beginsAt: Date

    @NSManaged public var endsAt: Date

    @NSManaged public var coursesBeginAt: Date

    @NSManaged public var coursesEndAt: Date

    // MARK: Managing Metadata

    @NSManaged public var summary: String?

    @NSManaged public var state: SemesterState

    // MARK: - Life Cycle

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)
        state = SemesterState(createIn: context)
    }

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \Semester.beginsAt, ascending: false),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<Semester id: \(id), title: \(title)>"
    }
}

// MARK: - Utilities

public extension Semester {
    public var isCurrent: Bool {
        let now = Date()
        return now >= beginsAt && now <= endsAt
    }

    public var monthRange: String {
        return "\(beginsAt.formatted(using: .monthAndYear)) – \(endsAt.formatted(using: .monthAndYear))"
    }
}
