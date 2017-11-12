//
//  RootItem.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 29.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import MobileCoreServices
import StudKit

final class RootItem: NSObject, NSFileProviderItem {
    let itemIdentifier: NSFileProviderItemIdentifier = .rootContainer
    let filename: String = "Semesters"
    let typeIdentifier: String = kUTTypeFolder as String
    let capabilities: NSFileProviderItemCapabilities = [.allowsContentEnumerating, .allowsReading]
    let childItemCount: NSNumber?
    let parentItemIdentifier: NSFileProviderItemIdentifier = .rootContainer

    init(childItemCount: Int) {
        self.childItemCount = childItemCount as NSNumber
    }

    convenience init(context: NSManagedObjectContext) throws {
        let childItemCount = try context.count(for: Semester.fetchRequest())
        self.init(childItemCount: childItemCount)
    }
}
