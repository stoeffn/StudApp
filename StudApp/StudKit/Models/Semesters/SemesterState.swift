//
//  SemesterState.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(SemesterState)
public final class SemesterState: NSManagedObject, CDCreatable, CDSortable {

    // MARK: Specifying Location

    @NSManaged public var semester: Semester

    // MARK: Tracking Usage

    @NSManaged public var lastUsedAt: Date?

    // MARK: Managing Metadata

    @NSManaged public var favoriteRank: Int

    @NSManaged public var tagData: Data?

    // MARK: Managing State

    @NSManaged public var isHidden: Bool

    @NSManaged public var isCollapsed: Bool

    // MARK: - Life Cycle

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)

        favoriteRank = fileProviderFavoriteRankUnranked
    }

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \SemesterState.semester.beginsAt, ascending: false),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<SemesterState: \(semester)>"
    }
}
