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

// MARK: - Fetching

public extension NSFetchRequestResult {
    /// Returns a fetch request for this object, using the parameters given as its properties.
    public static func fetchRequest(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = [],
                                    limit: Int? = nil, offset: Int? = nil, batchSize: Int? = nil,
                                    relationshipKeyPathsForPrefetching: [String] = []) -> NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = limit ?? request.fetchLimit
        request.fetchOffset = offset ?? request.fetchOffset
        request.fetchBatchSize = batchSize ?? request.fetchBatchSize
        request.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching
        return request
    }

    /// Returns an array of all objects of that type in a given context sorted by `sortDescriptors`.
    public static func fetch(in context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor] = []) throws -> [Self] {
        return try context.fetch(fetchRequest(sortDescriptors: sortDescriptors))
    }
}

// MARK: - Switching Contexts

public extension NSFetchRequestResult where Self: NSManagedObject {
    public func `in`(_ context: NSManagedObjectContext) -> Self {
        guard let object = context.object(with: objectID) as? Self else {
            fatalError("Cannot find object '\(self)' in context '\(context)'.")
        }
        return object
    }
}

// MARK: - Updating

extension NSFetchRequestResult where Self: NSManagedObject {
    func shouldUpdate(lastUpdatedAt: Date?, expiresAfter: TimeInterval) -> Bool {
        guard let lastUpdatedAt = lastUpdatedAt else { return true }
        return lastUpdatedAt + expiresAfter < Date()
    }

    func update<Value>(lastUpdatedAt lastUpdatedAtKeyPath: ReferenceWritableKeyPath<Self, Date?>,
                       expiresAfter: TimeInterval, forced: Bool = false, completion: @escaping ResultHandler<Value>,
                       updater: @escaping (@escaping ResultHandler<Value>) -> Void) {
        guard let context = managedObjectContext else { fatalError() }
        let lastUpdatedAt = self[keyPath: lastUpdatedAtKeyPath]

        guard forced || shouldUpdate(lastUpdatedAt: lastUpdatedAt, expiresAfter: expiresAfter) else {
            return completion(.failure(nil))
        }

        self[keyPath: lastUpdatedAtKeyPath] = Date()

        context.perform {
            updater { result in
                guard result.isSuccess else {
                    self[keyPath: lastUpdatedAtKeyPath] = lastUpdatedAt
                    return completion(result)
                }

                do {
                    try context.save()
                    completion(result)
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
