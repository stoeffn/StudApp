//
//  CourseState.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

/// Represents the current state of a course.
@objc(CourseState)
public final class CourseState: NSManagedObject, CDCreatable, CDSortable {
    @NSManaged public var lastUsedAt: Date?

    @NSManaged public var favoriteRank: Int

    @NSManaged public var tagData: Data?

    @NSManaged public var colorId: Int

    @NSManaged public var areFilesFetchedFromRemote: Bool

    @NSManaged public var course: Course

    // MARK: Life Cycle

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)

        favoriteRank = defaultFavoriteRank
    }

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \CourseState.course.title, ascending: true),
    ]
}
