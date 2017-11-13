//
//  CDCreatable.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

/// Something that can be created in a core data context, usually an `NSManagedObject`.
public protocol CDCreatable {
    /// Creates this object in the context given.
    ///
    /// - Parameter context: Managed object context.
    /// - Remarks: Default constructor generatted by `NSManagedObject`.
    /// - Warning: When creating objects, use `init(createIn: NSManagedObjectContext` instead as it may contain additional
    ///            initilization logic.
    init(context: NSManagedObjectContext)

    /// Creates this object in the context given.
    ///
    /// - Parameter context: Managed object context.
    init(createIn context: NSManagedObjectContext)
}

// MARK: - Default Implementation

extension CDCreatable where Self: CDCreatable {
    public init(createIn context: NSManagedObjectContext) {
        self.init(context: context)
    }
}

// MARK: - Utilities

extension CDCreatable where Self : NSManagedObject {
    /// Specifies that this object should be removed from its persistent store when changes are committed. When changes are
    /// committed, the object will be removed from the uniquing tables. If object has not yet been saved to a persistent store,
    /// it is simply removed from `context`.
    ///
    /// - Parameter context: Managed object context.
    func delete(in context: NSManagedObjectContext) {
        context.delete(self)
    }
}
