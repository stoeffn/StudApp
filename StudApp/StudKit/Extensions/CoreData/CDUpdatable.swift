//
//  CDUpdatable.swift
//  StudKit
//
//  Created by Steffen Ryll on 27.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

protocol CDUpdatable {}

extension CDUpdatable where Self: NSManagedObject {
    static func update<Model: CDConvertible>(using result: Result<[Model]>, in context: NSManagedObjectContext,
                                             handler: @escaping ResultHandler<[Self]>) {
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
}
