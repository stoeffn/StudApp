//
//  Color.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(Color)
public final class Color: NSManagedObject, CDCreatable {
    @NSManaged public var orderId: Int
    @NSManaged public var uiColor: UIColor

    @NSManaged public var courseStates: Set<CourseState>

    public convenience init(createIn context: NSManagedObjectContext, orderId: Int, uiColor: UIColor) {
        self.init(createIn: context)
        self.orderId = orderId
        self.uiColor = uiColor
    }
}

// MARK: - Core Data Operation

extension Color {
    public static func `default`(in context: NSManagedObjectContext) throws -> Color? {
        let predicate = NSPredicate(format: "orderId == 0")
        return try context.fetch(fetchRequest(predicate: predicate)).first
    }

    @discardableResult
    public static func createNewColorsWhenNeeded(in _: NSManagedObjectContext) -> [Color] {
        fatalError("Not implemented.")
    }
}
