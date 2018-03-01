//
//  OrganizationState.swift
//  StudKit
//
//  Created by Steffen Ryll on 01.03.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(OrganizationState)
public final class OrganizationState: NSManagedObject, CDCreatable, CDSortable {

    // MARK: Specifying Location

    @NSManaged public var organization: Organization

    // MARK: Tracking Usage

    @NSManaged public var discoveryUpdatedAt: Date?

    @NSManaged public var semestersUpdatedAt: Date?

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \Organization.title, ascending: true),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<OrganizationState: \(organization)>"
    }
}
