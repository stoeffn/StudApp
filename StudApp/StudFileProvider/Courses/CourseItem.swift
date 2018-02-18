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

    init(from course: Course, childItemCount: Int?) {
        itemIdentifier = NSFileProviderItemIdentifier(rawValue: course.objectIdentifier.rawValue)
        filename = course.title.sanitizedAsFilename

        self.childItemCount = childItemCount as NSNumber?

        lastUsedDate = course.state.lastUsedAt

        ownerNameComponents = course.lecturers.first?.nameComponents

        tagData = course.state.tagData
        favoriteRank = !course.state.isUnranked ? course.state.favoriteRank as NSNumber : nil
    }

    convenience init(from course: Course) {
        let childItemCount = course.state.areFilesFetchedFromRemote
            ? try? course.managedObjectContext?.count(for: course.childFileStatesFetchRequest) ?? 0
            : nil

        self.init(from: course, childItemCount: childItemCount)
    }

    // MARK: - File Provider Item Conformance

    // MARK: Required Properties

    let itemIdentifier: NSFileProviderItemIdentifier

    let filename: String

    let typeIdentifier = kUTTypeFolder as String

    let capabilities: NSFileProviderItemCapabilities = [.allowsContentEnumerating, .allowsReading]

    // MARK: Managing Content

    let childItemCount: NSNumber?

    let documentSize: NSNumber? = nil

    // MARK: Specifying Content Location

    let parentItemIdentifier = NSFileProviderItemIdentifier.rootContainer

    // MARK: Tracking Usage

    let lastUsedDate: Date?

    // MARK: Sharing

    let isShared = true

    let ownerNameComponents: PersonNameComponents?

    // MARK: Managing Metadata

    let tagData: Data?

    let favoriteRank: NSNumber?
}
