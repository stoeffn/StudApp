//
//  ObjectIdentifier.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public struct ObjectIdentifier: ByTypeNameIdentifiable {
    public let entity: Entites

    let id: String?

    init(entity: Entites, id: String? = nil) {
        self.entity = entity
        self.id = id
    }
}

// MARK: - Entities

public extension ObjectIdentifier {
    public enum Entites: String {
        case announcement, course, courseState, event, file, fileState, organization, root, semester, semesterState, user, workingSet
    }
}

// MARK: - Utilities

public extension ObjectIdentifier {
    public func fetch(in context: NSManagedObjectContext) throws -> CDIdentifiable? {
        switch entity {
        case .root, .workingSet:
            fatalError("Cannot fetch object for root container or working set.")
        default:
            guard let id = id else { return nil }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue.capitalized)
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            return try context.fetch(fetchRequest).first as? CDIdentifiable
        }
    }
}

// MARK: - Coding

extension ObjectIdentifier: RawRepresentable {
    public typealias RawValue = String

    private static let rawValueSeparator = "-"

    private static let rootEntityRawValue: String = {
        guard #available(iOS 11, *) else { return "root" }
        return NSFileProviderItemIdentifier.rootContainer.rawValue
    }()

    private static let workingSetEntityRawValue: String = {
        guard #available(iOS 11, *) else { return "workingSet" }
        return NSFileProviderItemIdentifier.workingSet.rawValue
    }()

    public init?(rawValue: String) {
        let parts = rawValue.components(separatedBy: ObjectIdentifier.rawValueSeparator)

        switch parts.first {
        case ObjectIdentifier.rootEntityRawValue?:
            self.init(entity: .root)
        case ObjectIdentifier.workingSetEntityRawValue?:
            self.init(entity: .workingSet)
        default:
            guard
                let entityName = parts.first,
                let entity = Entites(rawValue: entityName),
                let id = parts.last,
                parts.count == 2
            else { return nil }
            self.init(entity: entity, id: id)
        }
    }

    public var rawValue: String {
        switch entity {
        case .root:
            return ObjectIdentifier.rootEntityRawValue
        case .workingSet:
            return ObjectIdentifier.workingSetEntityRawValue
        default:
            guard let id = id else { fatalError("Cannot create object identifier representation for object without id.") }
            return entity.rawValue + ObjectIdentifier.rawValueSeparator + id
        }
    }
}
