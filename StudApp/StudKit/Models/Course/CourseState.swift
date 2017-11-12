//
//  CourseState.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(CourseState)
public final class CourseState: NSManagedObject, CDCreatable, CDColorable {
    @NSManaged public var lastUsedDate: Date?
    @NSManaged public var favoriteRank: Int
    @NSManaged public var tagData: Data?

    @NSManaged public var color: Color?
    @NSManaged public var course: Course

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)

        favoriteRank = Int(NSFileProviderFavoriteRankUnranked)
        if let color = try? Color.default(in: context) {
            self.color = color
        }
    }
}
