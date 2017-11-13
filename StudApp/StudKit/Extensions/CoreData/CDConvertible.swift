//
//  CDConvertible.swift
//  StudKit
//
//  Created by Steffen Ryll on 27.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

/// Something that can be converted to a core data managed object, e.g. a structure parsed from JSON.
protocol CDConvertible {
    /// Creates or updates a core data managed object using this object.
    ///
    /// - Remark: Implementations may fetch and update objects instead of creating them every time.
    /// - Parameter context: Managed object context.
    /// - Returns: Converted core data managed object.
    @discardableResult
    func coreDataModel(in context: NSManagedObjectContext) throws -> NSManagedObject
}
