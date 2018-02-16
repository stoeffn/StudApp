//
//  CDUpdatable.swift
//  StudKit
//
//  Created by Steffen Ryll on 27.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

/// Something that can be updated in Core Data.
protocol CDUpdatable {}

// MARK: - Default Implementation

extension CDUpdatable where Self: NSManagedObject {
    /// Updates core data objects of this type using the result given. This includes inserting objects that are new in `result`
    /// and updating properties of existing objects by overriding properties.
    @discardableResult
    static func update<Model: CDConvertible>(using models: [Model], in context: NSManagedObjectContext) throws -> [Self] {
        // TODO: Add ability to remove stale objects.
        return try models.flatMap { try $0.coreDataObject(in: context) as? Self }
    }
}
