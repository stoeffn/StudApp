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
    private let coreDataService: CoreDataService

    // MARK: - Life Cycle

    override init() {
        ServiceContainer.default.register(providers: StudKitServiceProvider())
        coreDataService = ServiceContainer.default[CoreDataService.self]
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

    static func model(for identifier: NSFileProviderItemIdentifier,
                      in context: NSManagedObjectContext) throws -> FileProviderItemConvertible? {
        switch identifier.model {
        case .root, .workingSet:
            fatalError("Cannot fetch model of root container or working set.")
        case let .semester(id):
            return try Semester.fetch(byId: id, in: context)
        case let .course(id):
            return try Course.fetch(byId: id, in: context)
        case let .file(id):
            return try File.fetch(byId: id, in: context)
        }
    }

    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
        switch identifier.model {
        case .workingSet:
            throw "Not implemented: Working Set Item"
        case .root:
            return try RootItem(context: coreDataService.viewContext)
        case .semester, .course, .file:
            guard let model = try? FileProviderExtension.model(for: identifier, in: coreDataService.viewContext),
                let unwrappedModel = model,
                let item = try? unwrappedModel.fileProviderItem(context: coreDataService.viewContext) else {
                throw NSFileProviderError(.noSuchItem)
            }
            return item
        }
    }

    // MARK: - Enumeration

    override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        switch containerItemIdentifier.model {
        case .workingSet:
            return WorkingSetEnumerator()
        case .root:
            return SemesterEnumerator(itemIdentifier: containerItemIdentifier)
        case .semester:
            return CourseEnumerator(itemIdentifier: containerItemIdentifier)
        case .course:
            return FileEnumerator(itemIdentifier: containerItemIdentifier)
        case .file:
            return FileEnumerator(itemIdentifier: containerItemIdentifier)
        }
    }

    // MARK: - Providing Files

    func startProvidingDownloaded(file: File, completionHandler: ((_ error: Error?) -> Void)?) throws {
        let destination = urlForItem(withPersistentIdentifier: file.itemIdentifier)!
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.copyItem(at: file.localUrl, to: destination)
        completionHandler?(nil)
    }

    func startProvidingRemote(file: File, completionHandler: ((_ error: Error?) -> Void)?) throws {
        file.download { result in
            guard result.isSuccess else {
                completionHandler?(NSFileProviderError(.serverUnreachable))
                return
            }
            do {
                try self.startProvidingDownloaded(file: file, completionHandler: completionHandler)
            } catch {
                completionHandler?(error)
            }
        }
    }

    override func startProvidingItem(at url: URL, completionHandler: ((_ error: Error?) -> Void)?) {
        guard let itemIdentifier = persistentIdentifierForItem(at: url) else {
            completionHandler?(NSFileProviderError(.noSuchItem))
            return
        }
        do {
            guard let file = try File.fetch(byId: itemIdentifier.id, in: coreDataService.viewContext) else {
                completionHandler?(NSFileProviderError(.noSuchItem))
                return
            }
            if File.isDownloaded(id: itemIdentifier.id) {
                try startProvidingDownloaded(file: file, completionHandler: completionHandler)
            } else {
                try startProvidingRemote(file: file, completionHandler: completionHandler)
            }
        } catch {
            completionHandler?(error)
        }
    }

    override func itemChanged(at _: URL) {}

    override func stopProvidingItem(at url: URL) {
        try? FileManager.default.removeItem(at: url)
        providePlaceholder(at: url) { error in
            print(error as Any)
        }
    }

    override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        guard let identifier = persistentIdentifierForItem(at: url) else {
            return completionHandler(NSFileProviderError(.noSuchItem))
        }
        do {
            let placeholderUrl = NSFileProviderManager.placeholderURL(for: url)
            try FileManager.default.createIntermediateDirectories(forFileAt: placeholderUrl)
            try NSFileProviderManager.writePlaceholder(at: placeholderUrl, withMetadata: item(for: identifier))
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }

    // MARK: - Modifying Meta Data

    private func modifyItem(withIdentifier identifier: NSFileProviderItemIdentifier,
                            completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void,
                            task: ((inout FileProviderItemConvertible?) -> Void)) {
        do {
            var model = try FileProviderExtension.model(for: identifier, in: coreDataService.viewContext)
            task(&model)
            try coreDataService.viewContext.save()

            guard let item = try model?.fileProviderItem(context: coreDataService.viewContext) else {
                return completionHandler(nil, NSFileProviderError(.noSuchItem))
            }

            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: identifier) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: item.parentItemIdentifier) { _ in }

            completionHandler(item, nil)
        } catch {
            completionHandler(nil, NSFileProviderError(.noSuchItem))
        }
    }

    override func setLastUsedDate(_ lastUsedDate: Date?, forItemIdentifier itemIdentifier: NSFileProviderItemIdentifier,
                                  completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        modifyItem(withIdentifier: itemIdentifier, completionHandler: completionHandler) { model in
            model?.itemState.lastUsedDate = lastUsedDate
        }
    }

    override func setFavoriteRank(_ favoriteRank: NSNumber?, forItemIdentifier itemIdentifier: NSFileProviderItemIdentifier,
                                  completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        modifyItem(withIdentifier: itemIdentifier, completionHandler: completionHandler) { model in
            model?.itemState.favoriteRank = favoriteRank?.intValue ?? Int(NSFileProviderFavoriteRankUnranked)
        }
    }

    override func setTagData(_ tagData: Data?, forItemIdentifier itemIdentifier: NSFileProviderItemIdentifier,
                             completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        modifyItem(withIdentifier: itemIdentifier, completionHandler: completionHandler) { model in
            model?.itemState.tagData = tagData
        }
    }
}
