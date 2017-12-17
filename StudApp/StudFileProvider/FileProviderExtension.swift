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
    private let storeService: StoreService
    private let studIpService: StudIpService

    // MARK: - Life Cycle

    override init() {
        ServiceContainer.default.register(providers: StudKitServiceProvider(currentTarget: .fileProvider))

        coreDataService = ServiceContainer.default[CoreDataService.self]
        storeService = ServiceContainer.default[StoreService.self]
        studIpService = ServiceContainer.default[StudIpService.self]

        let historyService = ServiceContainer.default[HistoryService.self]
        try? historyService.mergeHistory(into: coreDataService.viewContext)
        try? historyService.deleteHistory(mergedInto: Targets.iOSTargets, in: coreDataService.viewContext)
    }

    // MARK: - Working with Items and Persistent Identifiers

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
        guard
            let item = try? item(for: identifier),
            let fileItem = item as? FileItem,
            let filename = fileItem.internalFilename
        else { return nil }

        return containerUrlForItem(withPersistentIdentifier: identifier)
            .appendingPathComponent(filename, isDirectory: false)
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

    override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        guard studIpService.isSignedIn else {
            throw NSFileProviderError(.notAuthenticated, userInfo: [
                NSFileProviderError.reasonKey: NSFileProviderError.Reasons.notSignedIn.rawValue,
            ])
        }
        guard storeService.state.isUnlocked else {
            throw NSFileProviderError(.notAuthenticated, userInfo: [
                NSFileProviderError.reasonKey: NSFileProviderError.Reasons.noVerifiedPurchase.rawValue,
            ])
        }

        switch containerItemIdentifier.model {
        case .workingSet:
            return WorkingSetEnumerator()
        case .root:
            return SemesterEnumerator()
        case .semester:
            return CourseEnumerator(itemIdentifier: containerItemIdentifier)
        case .course:
            return FileEnumerator(itemIdentifier: containerItemIdentifier)
        case .file:
            return FileEnumerator(itemIdentifier: containerItemIdentifier)
        }
    }

    // MARK: - Managing Shared Files

    override func itemChanged(at _: URL) {}

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

    override func startProvidingItem(at url: URL, completionHandler: ((_ error: Error?) -> Void)?) {
        guard
            let itemIdentifier = persistentIdentifierForItem(at: url),
            let optionalFile = try? File.fetch(byId: itemIdentifier.id, in: coreDataService.viewContext),
            let file = optionalFile,
            let itemUrl = self.urlForItem(withPersistentIdentifier: file.itemIdentifier)
        else {
            completionHandler?(NSFileProviderError(.noSuchItem))
            return
        }

        guard !file.isFolder else {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                completionHandler?(error)
                return
            }

            completionHandler?(nil)
            return
        }

        file.download { result in
            guard result.isSuccess else {
                completionHandler?(NSFileProviderError(.serverUnreachable))
                return
            }

            do {
                try? FileManager.default.removeItem(at: itemUrl)
                try FileManager.default.createIntermediateDirectories(forFileAt: itemUrl)
                try FileManager.default.copyItem(at: file.localUrl(), to: itemUrl)
                completionHandler?(nil)
            } catch {
                completionHandler?(error)
            }
        }
    }

    override func stopProvidingItem(at url: URL) {
        providePlaceholder(at: url) { _ in
            try? FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - Handling Actions

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
            model?.itemState.lastUsedAt = lastUsedDate
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
