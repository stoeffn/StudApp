//
//  CourseItem.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 16.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import MobileCoreServices
import StudKit

final class CourseItem: NSObject, NSFileProviderItem {
    let itemIdentifier: NSFileProviderItemIdentifier
    let filename: String
    let typeIdentifier: String = kUTTypeFolder as String
    let capabilities: NSFileProviderItemCapabilities = [.allowsContentEnumerating, .allowsReading]
    let childItemCount: NSNumber?
    let parentItemIdentifier: NSFileProviderItemIdentifier
    let lastUsedDate: Date?
    let tagData: Data?
    let favoriteRank: NSNumber?
    let isShared: Bool = true
    let ownerNameComponents: PersonNameComponents?

    init(from course: Course, childItemCount: Int, parentItemIdentifier: NSFileProviderItemIdentifier = .rootContainer) {
        itemIdentifier = course.itemIdentifier
        filename = course.title
        self.childItemCount = childItemCount as NSNumber
        self.parentItemIdentifier = parentItemIdentifier
        lastUsedDate = course.state.lastUsedDate
        tagData = course.state.tagData
        favoriteRank = course.state.favoriteRank != NSFileProviderFavoriteRankUnranked
            ? course.state.favoriteRank as NSNumber : nil
        ownerNameComponents = course.lecturers.first?.nameComponents
    }

    convenience init(from course: Course, context _: NSManagedObjectContext,
                     parentItemIdentifier: NSFileProviderItemIdentifier = .rootContainer) throws {
        let childItemCount = 42
        self.init(from: course, childItemCount: childItemCount, parentItemIdentifier: parentItemIdentifier)
    }

    convenience init(byId id: String, context: NSManagedObjectContext,
                     parentItemIdentifier: NSFileProviderItemIdentifier = .rootContainer) throws {
        guard let course = try Course.fetch(byId: id, in: context) else { throw NSFileProviderError(.noSuchItem) }
        try self.init(from: course, context: context, parentItemIdentifier: parentItemIdentifier)
    }
}
