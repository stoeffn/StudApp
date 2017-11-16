//
//  CDUpdatable.swift
//  StudKit
//
//  Created by Steffen Ryll on 27.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

/// Something that can be updated in core data.
protocol CDUpdatable {}

// MARK: - Default Implementation

extension CDUpdatable where Self: NSManagedObject {
    /// Updates core data objects of this type using the result given. This includes inserting objects that are new in `result`
    /// and updating properties of existing objects by overriding properties.
    static func update<Model: CDConvertible>(using result: Result<[Model]>, in context: NSManagedObjectContext,
                                             handler: @escaping ResultHandler<[Self]>) {
        // TODO: Use a sequence instead of a result as input.
        // TODO: Add ability to remove stale objects.
        guard let models = result.value else {
            return handler(result.replacingValue(nil))
        }
        do {
            let coreDataModels = try models.flatMap { try $0.coreDataModel(in: context) as? Self }
            handler(result.replacingValue(coreDataModels))
        } catch {
            handler(.failure(error))
        }
    }

    /// Updates or inserts one core data object of this type using the result given.
    static func update<Model: CDConvertible>(using result: Result<Model>, in context: NSManagedObjectContext,
                                             handler: @escaping ResultHandler<Self>) {
        // TODO: Use an object instead of a result as input.
        // TODO: Add ability to remove stale objects.
        guard let value = result.value else {
            return handler(result.replacingValue(nil))
        }
        return update(using: result.replacingValue([value]), in: context) { result in
            handler(result.replacingValue(result.value?.first))
        }
    }
}
