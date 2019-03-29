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

/// Something, usually a core data managed object, that can be uniquely identified.
public protocol CDIdentifiable {
    static var entity: ObjectIdentifier.Entites { get }

    /// Identifier that uniquely identifies this object.
    var id: String { get set }
}

// MARK: - Fetching Objects

public extension CDIdentifiable where Self: NSFetchRequestResult {
    /// Fetches an object by the identifier given.
    ///
    /// - Parameters:
    ///   - id: Identifier to search for.
    ///   - context: Managed object context.
    /// - Returns: Object if found, `nil` otherwise.
    static func fetch(byId id: String?, in context: NSManagedObjectContext) throws -> Self? {
        guard let id = id else { return nil }
        let predicate = NSPredicate(format: "id == %@", id)
        return try context.fetch(Self.fetchRequest(predicate: predicate, limit: 1)).first
    }

    static func fetch(byIds ids: Set<String>, in context: NSManagedObjectContext) throws -> [Self] {
        let predicate = NSPredicate(format: "id IN %@", ids)
        return try context.fetch(Self.fetchRequest(predicate: predicate, limit: ids.count))
    }
}

// MARK: - Creating Objects

public extension CDIdentifiable where Self: CDCreatable {
    init(createWithId id: String, in context: NSManagedObjectContext) {
        self.init(createIn: context)
        self.id = id
    }
}

// MARK: - Fetching and Creating Objects

public extension CDIdentifiable where Self: NSFetchRequestResult & CDCreatable {
    /// Fetches an object by the identifier given. If there is no match, a new object will be created.
    ///
    /// - Parameters:
    ///   - id: Identifier to search for.
    ///   - context: Managed object context.
    /// - Returns: Tuple containing the object and a boolean indicating whether it was newly created during this operation.
    static func fetch(byId id: String, orCreateIn context: NSManagedObjectContext) throws -> (Self, isNew: Bool) {
        let result = try fetch(byId: id, in: context).map { ($0, isNew: false) }
        return result ?? (Self(createWithId: id, in: context), isNew: true)
    }
}

// MARK: - Managing Object Identifiers

extension CDIdentifiable {
    public var objectIdentifier: ObjectIdentifier {
        return ObjectIdentifier(entity: Self.entity, id: id)
    }
}

extension CDIdentifiable where Self: NSFetchRequestResult {
    public static func fetch(byObjectId objectId: ObjectIdentifier?, in context: NSManagedObjectContext? = nil) -> Self? {
        let context = context ?? ServiceContainer.default[CoreDataService.self].viewContext

        guard objectId?.entity == Self.entity, let id = objectId?.id else { return nil }
        return try? Self.fetch(byId: id, in: context)
    }
}

// MARK: - Updating Objects

extension CDIdentifiable where Self: NSManagedObject {
    @discardableResult
    static func update<Value, Values: Sequence>(_ existingObjectsFetchRequest: NSFetchRequest<Self>? = nil,
                                                with values: Values, in context: NSManagedObjectContext,
                                                deleteHandler: ((Self) -> Void)? = nil,
                                                transform: (Value) throws -> Self) throws -> [Self] where Values.Element == Value {
        let existingObjectsFetchRequest = existingObjectsFetchRequest ?? Self.fetchRequest(predicate: NSPredicate(value: false))
        existingObjectsFetchRequest.propertiesToFetch = ["id"]

        let existingObjects = try context.fetch(existingObjectsFetchRequest)
        let existingIds = existingObjects.map { $0.id }

        let updatedObjects = try values.map(transform)
        let updatedIds = updatedObjects.map { $0.id }

        let deletedIds = Set(existingIds).subtracting(updatedIds)
        let deletedObjects = existingObjects.filter { deletedIds.contains($0.id) }
        deletedObjects.forEach(deleteHandler ?? context.delete)

        return updatedObjects
    }
}
