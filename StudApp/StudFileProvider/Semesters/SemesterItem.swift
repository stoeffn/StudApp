//
//  SemesterItem.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import FileProvider
import MobileCoreServices
import StudKit

final class SemesterItem: NSObject, NSFileProviderItem {
    let itemIdentifier: NSFileProviderItemIdentifier
    let filename: String
    let typeIdentifier: String = kUTTypeFolder as String
    let capabilities: NSFileProviderItemCapabilities = [.allowsContentEnumerating, .allowsReading]
    let childItemCount: NSNumber?
    let parentItemIdentifier: NSFileProviderItemIdentifier
    let lastUsedDate: Date?
    let tagData: Data?
    let favoriteRank: NSNumber?

    init(from semester: Semester, childItemCount: Int, parentItemIdentifier: NSFileProviderItemIdentifier = .rootContainer) {
        itemIdentifier = semester.itemIdentifier
        filename = semester.title
        self.childItemCount = childItemCount as NSNumber
        self.parentItemIdentifier = parentItemIdentifier
        lastUsedDate = semester.state.lastUsedDate
        tagData = semester.state.tagData
        favoriteRank = semester.state.favoriteRank != NSFileProviderFavoriteRankUnranked
            ? semester.state.favoriteRank as NSNumber : nil
    }

    convenience init(from semester: Semester) throws {
        let childItemCount = semester.courses.count
        self.init(from: semester, childItemCount: childItemCount, parentItemIdentifier: .rootContainer)
    }
}
