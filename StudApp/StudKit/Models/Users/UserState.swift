//
//  UserState.swift
//  StudKit
//
//  Created by Steffen Ryll on 01.03.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(UserState)
public final class UserState: NSManagedObject, CDCreatable, CDSortable {

    // MARK: Specifying Location

    @NSManaged public var user: User

    // MARK: Tracking Usage

    @NSManaged public var authoredCoursesUpdatedAt: Date?

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \UserState.user.username, ascending: true),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<UserState: \(user)>"
    }
}
