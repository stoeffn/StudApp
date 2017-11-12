//
//  SemesterState.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(SemesterState)
public final class SemesterState: NSManagedObject, CDCreatable {
    @NSManaged public var lastUsedDate: Date?
    @NSManaged public var favoriteRank: Int
    @NSManaged public var tagData: Data?
    @NSManaged public var isHidden: Bool

    @NSManaged public var semester: Semester

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)

        favoriteRank = Int(NSFileProviderFavoriteRankUnranked)
    }
}
