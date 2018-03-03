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

@available(iOSApplicationExtension 11.0, *)
final class RootItem: NSObject, NSFileProviderItem {

    // MARK: - Life Cycle

    init(childItemCount: Int?) {
        self.childItemCount = childItemCount as NSNumber?
    }

    convenience init(context: NSManagedObjectContext) throws {
        let childItemCount = User.current?.authoredCourses.count
        self.init(childItemCount: childItemCount)
    }

    // MARK: - File Provider Item Conformance

    // MARK: Required Properties

    let itemIdentifier: NSFileProviderItemIdentifier = .rootContainer

    let filename = "Stud.IP"

    let typeIdentifier = kUTTypeFolder as String

    let capabilities: NSFileProviderItemCapabilities = [.allowsContentEnumerating, .allowsReading]

    // MARK: Managing Content

    let childItemCount: NSNumber?

    // MARK: Specifying Content Location

    let parentItemIdentifier: NSFileProviderItemIdentifier = .rootContainer
}
