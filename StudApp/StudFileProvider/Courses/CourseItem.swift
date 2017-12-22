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

@available(iOSApplicationExtension 11.0, *)
final class CourseItem: NSObject, NSFileProviderItem {
    // MARK: - Life Cycle

    init(from course: Course, childItemCount: Int?, parentItemIdentifier: NSFileProviderItemIdentifier = .rootContainer) {
        itemIdentifier = course.itemIdentifier
        filename = course.title

        self.childItemCount = childItemCount as NSNumber?

        self.parentItemIdentifier = parentItemIdentifier

        lastUsedDate = course.state.lastUsedAt

        ownerNameComponents = course.lecturers.first?.nameComponents

        tagData = course.state.tagData
        favoriteRank = !course.state.isUnranked
            ? course.state.favoriteRank as NSNumber
            : nil
    }

    convenience init(from course: Course, context: NSManagedObjectContext) throws {
        guard let parentItemIdentifier = course.semesters.first?.itemIdentifier else { throw NSFileProviderError(.noSuchItem) }
        let childItemCount = course.state.areFilesFetchedFromRemote
            ? try context.count(for: course.rootFilesFetchRequest)
            : nil
        self.init(from: course, childItemCount: childItemCount, parentItemIdentifier: parentItemIdentifier)
    }

    // MARK: - File Provider Item Conformance

    // MARK: Required Properties

    let itemIdentifier: NSFileProviderItemIdentifier

    let filename: String

    let typeIdentifier = kUTTypeFolder as String

    let capabilities: NSFileProviderItemCapabilities = [.allowsContentEnumerating, .allowsReading]

    // MARK: Managing Content

    let childItemCount: NSNumber?

    // MARK: Specifying Content Location

    let parentItemIdentifier: NSFileProviderItemIdentifier

    // MARK: Tracking Usage

    let lastUsedDate: Date?

    // MARK: Sharing

    let isShared = true

    let ownerNameComponents: PersonNameComponents?

    // MARK: Managing Metadata

    let tagData: Data?

    let favoriteRank: NSNumber?
}
