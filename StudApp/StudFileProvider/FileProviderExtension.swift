//
//  FileProviderExtension.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import FileProvider
import StudKit

final class FileProviderExtension: NSFileProviderExtension {
    // MARK: - Life Cycle

    override init() {
        ServiceContainer.default.register(providers: StudKitServiceProvider())
    }

    // MARK: - Providing Meta Data

    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
        // Exploit the fact that the path structure has been defined as
        // <base storage directory>/<item identifier>/<item file name>
        guard url.pathComponents.count >= 2 else { return nil }
        let id = url.pathComponents[url.pathComponents.count - 2]
        return File.itemIdentifier(forId: id)
    }

    func containerUrlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL {
        return NSFileProviderManager.default.documentStorageURL
            .appendingPathComponent(identifier.id, isDirectory: true)
    }

    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        guard let item = try? item(for: identifier) else { return nil }
        return containerUrlForItem(withPersistentIdentifier: identifier)
            .appendingPathComponent(item.filename, isDirectory: false)
    }

    func model(for identifier: NSFileProviderItemIdentifier,
               in context: NSManagedObjectContext) throws -> FileProviderItemConvertible? {
        switch identifier.modelType {
        case let .semester(id):
            return try Semester.fetch(byId: id, in: context)
        case let .course(id):
            return try Course.fetch(byId: id, in: context)
        case let .file(id):
            return try File.fetch(byId: id, in: context)
        case .root, .workingSet:
            fatalError("Cannot fetch model of root container or working set.")
        }
    }

    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
        switch identifier.modelType {
        case .root:
            return try RootItem(context: coreData.viewContext)
        case .workingSet:
            throw "Not implemented: Working Set Item"
        case let .semester(id):
            return try SemesterItem(byId: id, context: coreData.viewContext)
        case let .course(id):
            return try CourseItem(byId: id, context: coreData.viewContext)
        case let .file(id):
            return try FileItem(byId: id, context: coreData.viewContext)
        }
    }
}
