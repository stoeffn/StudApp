//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

import CoreData
import MobileCoreServices
import StudKit

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
        let childItemCount = course.state.childFilesUpdatedAt != nil
            ? try? course.managedObjectContext?.count(for: course.childFilesFetchRequest) ?? 0
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
