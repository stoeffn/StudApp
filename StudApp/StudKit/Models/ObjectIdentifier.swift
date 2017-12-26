//
//  ObjectIdentifier.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public struct ObjectIdentifier: ByTypeNameIdentifiable {
    let entityName: String

    let id: String?

    init(entityName: String, id: String? = nil) {
        self.entityName = entityName
        self.id = id
    }
}

// MARK: - Utilities

public extension ObjectIdentifier {
    public func isOf(type: CDIdentifiable.Type) -> Bool {
        return entityName == type.typeIdentifier
    }

    public func fetch(in context: NSManagedObjectContext) throws -> CDIdentifiable? {
        switch entityName {
        case ObjectIdentifier.rootTypeIdentifier, ObjectIdentifier.workingSetTypeIdentifier:
            fatalError("Cannot fetch object for root container or working set.")
        default:
            guard let id = id else { return nil }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            return try context.fetch(fetchRequest).first as? CDIdentifiable
        }
    }
}

// MARK: - Coding

extension ObjectIdentifier: RawRepresentable {
    public typealias RawValue = String

    private static let rawValueSeparator = "-"

    private static let rootTypeIdentifier: String = {
        guard #available(iOS 11, *) else { return "root" }
        return NSFileProviderItemIdentifier.rootContainer.rawValue
    }()

    private static let workingSetTypeIdentifier: String = {
        guard #available(iOS 11, *) else { return "workingSet" }
        return NSFileProviderItemIdentifier.workingSet.rawValue
    }()

    public init?(rawValue: String) {
        let parts = rawValue.components(separatedBy: ObjectIdentifier.rawValueSeparator)

        switch parts.first {
        case ObjectIdentifier.rootTypeIdentifier?:
            self.init(entityName: ObjectIdentifier.rootTypeIdentifier)
        case ObjectIdentifier.workingSetTypeIdentifier?:
            self.init(entityName: ObjectIdentifier.workingSetTypeIdentifier)
        default:
            guard
                let entityName = parts.first,
                let id = parts.last,
                parts.count == 2
            else { return nil }
            self.init(entityName: entityName, id: id)
        }
    }

    public var rawValue: String {
        switch entityName {
        case ObjectIdentifier.rootTypeIdentifier:
            return ObjectIdentifier.rootTypeIdentifier
        case ObjectIdentifier.workingSetTypeIdentifier:
            return ObjectIdentifier.workingSetTypeIdentifier
        default:
            guard let id = id else { fatalError("Cannot create object identifier representation for object without id.") }
            return entityName + ObjectIdentifier.rawValueSeparator + id
        }
    }
}
