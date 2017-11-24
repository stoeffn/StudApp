//
//  CoreDataService.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

/// Manages the Core Data stack.
public final class CoreDataService {
    private let modelName: String
    private let modelUrl: URL
    private let storeDescription: NSPersistentStoreDescription

    init(modelName: String, appGroupIdentifier: String? = nil, inMemory: Bool = false) {
        guard let modelUrl = StudKitServiceProvider.kitBundle.url(forResource: modelName, withExtension: "momd") else {
            fatalError("Failed to construct model URL for '\(modelName)'.")
        }
        let containerUrl: URL? = {
            guard let appGroupIdentifier = appGroupIdentifier else { return nil }
            return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
        }()

        self.modelName = modelName
        self.modelUrl = modelUrl
        storeDescription = inMemory
            ? CoreDataService.inMemoryStoreDescription()
            : CoreDataService.persistentStoreDescription(forStoreAt: containerUrl, modelName: modelName)
    }

    private static func persistentStoreDescription(forStoreAt containerUrl: URL?,
                                                   modelName: String) -> NSPersistentStoreDescription {
        let description: NSPersistentStoreDescription = {
            guard let storeUrl = containerUrl?.appendingPathComponent(modelName) else { return NSPersistentStoreDescription() }
            return NSPersistentStoreDescription(url: storeUrl)
        }()
        description.type = NSSQLiteStoreType
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        return description
    }

    private static func inMemoryStoreDescription() -> NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        return description
    }

    private lazy var persistentContainer: NSPersistentContainer = {
        guard let model = NSManagedObjectModel(contentsOf: modelUrl) else {
            fatalError("Failed to load managed object model at '\(modelUrl)'.")
        }
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return container
    }()

    /// The managed object context associated with the main queue.
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    /// Causes the persistent container to execute the block against a new private queue context.
    ///
    /// Each time this method is invoked, the persistent container creates a new `NSManagedObjectContext` with the
    /// `concurrencyType` set to `privateQueueConcurrencyType`. The persistent container then executes the passed in block
    /// against that newly created context on the context’s private queue.
    ///
    /// - Parameter task: A block that is executed by the persistent container against a newly created private context. The
    ///                    private context is passed into the block as part of the execution of the block.
    public func performBackgroundTask(task: @escaping (NSManagedObjectContext) -> Void) {
        return persistentContainer.performBackgroundTask(task)
    }

    func removeAllObjects(in context: NSManagedObjectContext) throws {
        try [Semester.fetchRequest(), Course.fetchRequest(), User.fetchRequest()]
            .flatMap { try context.fetch($0) }
            .flatMap { $0 as? NSManagedObject }
            .forEach { context.delete($0) }
    }
}
