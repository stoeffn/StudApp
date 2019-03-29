//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

import CoreData

/// Structure that can uniquely identify an object with an entity type and id.
public struct ObjectIdentifier: ByTypeNameIdentifiable {
    /// Entity type.
    public let entity: Entites

    /// Identifier unique per entity type. May be `nil` if there can be only one object.
    let id: String?

    /// Creates a new object identifier.
    ///
    /// - Parameters:
    ///   - entity: Entity type.
    ///   - id: Unique identifier within an entity type. May be `nil` if there can be only one object.
    init(entity: Entites, id: String? = nil) {
        self.entity = entity
        self.id = id
    }
}

// MARK: - Entities

public extension ObjectIdentifier {
    /// Available entity typs.
    enum Entites: String {
        case announcement, course, courseState, event, file, fileState, organization, root, semester, semesterState, user, workingSet
    }
}

// MARK: - Core Data Operations

public extension ObjectIdentifier {
    /// Fetches an object by its identifier in a context.
    ///
    /// - Parameter context: Context to fetch object in.
    /// - Returns: The object if found, `nil` otherwise.
    /// - Precondition: The _Core Data_ entity must be the capitalized entity type and it must conform to `CDIdentifiable`.
    func fetch(in context: NSManagedObjectContext) throws -> CDIdentifiable? {
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
