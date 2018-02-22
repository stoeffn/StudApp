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

    // MARK: Specifying Location

    @NSManaged public var course: Course

    // MARK: Tracking Usage

    @NSManaged public var lastUsedAt: Date?

    // MARK: Managing Metadata

    @NSManaged public var favoriteRank: Int

    @NSManaged public var tagData: Data?

    @NSManaged public var areFilesFetchedFromRemote: Bool

    // MARK: Life Cycle

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)

        favoriteRank = fileProviderFavoriteRankUnranked
    }

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \CourseState.course.groupId, ascending: true),
        NSSortDescriptor(keyPath: \CourseState.course.title, ascending: true),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<CourseState: \(course)>"
    }
}
