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

    // MARK: - Errors

    enum Errors: LocalizedError {
        case noSuchItem

        case serverUnreachable
    }

    // MARK: - Working with Items and Persistent Identifiers

    func object(for identifier: NSFileProviderItemIdentifier) -> FileProviderItemConvertible? {
        guard
            let itemConvertible = try? ObjectIdentifier(rawValue: identifier.rawValue)?
            .fetch(in: coreDataService.viewContext) as? FileProviderItemConvertible
        else { return nil }
        return itemConvertible
    }

    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
        let rawValue = url.deletingLastPathComponent().lastPathComponent
        return NSFileProviderItemIdentifier(rawValue: rawValue)
    }

    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        return object(for: identifier)?.localUrl(in: .fileProvider)
    }

    @available(iOSApplicationExtension 11.0, *)
    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
        let objectIdentifier = ObjectIdentifier(rawValue: identifier.rawValue)

        switch objectIdentifier?.entity {
        case .root?:
            return try RootItem(context: coreDataService.viewContext)
        case .semester?, .course?, .file?:
            guard let object = object(for: identifier) else { throw NSFileProviderError(.noSuchItem) }
            return object.fileProviderItem
        default:
            throw NSFileProviderError(.noSuchItem)
        }
    }

    override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        guard #available(iOS 11.0, *) else { fatalError() }
        guard studIpService.isSignedIn else {
            throw NSFileProviderError(.notAuthenticated, userInfo: [
                NSFileProviderError.reasonKey: NSFileProviderError.Reasons.notSignedIn.rawValue
            ])
        }

        let objectIdentifier = ObjectIdentifier(rawValue: containerItemIdentifier.rawValue)

        switch objectIdentifier?.entity {
        case .workingSet?:
            return WorkingSetEnumerator()
        case .root?:
            return SemesterEnumerator()
        case .semester?:
            return CourseEnumerator(itemIdentifier: containerItemIdentifier)
        case .course?:
            return FileEnumerator(itemIdentifier: containerItemIdentifier)
        case .file?:
            return FileEnumerator(itemIdentifier: containerItemIdentifier)
        default:
            throw NSFileProviderError(.noSuchItem)
        }
    }

    // MARK: - Managing Shared Files

    override func itemChanged(at _: URL) {}

    override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        guard let identifier = persistentIdentifierForItem(at: url) else {
            if #available(iOSApplicationExtension 11.0, *) {
                return completionHandler(NSFileProviderError(.noSuchItem))
            }
            return completionHandler(Errors.noSuchItem)
        }

        do {
            if #available(iOSApplicationExtension 11.0, *) {
                let placeholderUrl = NSFileProviderManager.placeholderURL(for: url)
                try FileManager.default.createIntermediateDirectories(forFileAt: placeholderUrl)
                try NSFileProviderManager.writePlaceholder(at: placeholderUrl, withMetadata: item(for: identifier))
            } else {
                let placeholderUrl = NSFileProviderExtension.placeholderURL(for: url)
                try FileManager.default.createIntermediateDirectories(forFileAt: placeholderUrl)
                try NSFileProviderExtension.writePlaceholder(at: placeholderUrl, withMetadata: [:])
            }
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }

    override func startProvidingItem(at url: URL, completionHandler: ((_ error: Error?) -> Void)?) {
        guard
            let itemIdentifier = persistentIdentifierForItem(at: url),
            let object = object(for: itemIdentifier)
        else {
            if #available(iOSApplicationExtension 11.0, *) {
                completionHandler?(NSFileProviderError(.noSuchItem))
            } else {
                completionHandler?(Errors.noSuchItem)
            }
            return
        }

        object.provide(at: url, handler: completionHandler)
    }

    override func stopProvidingItem(at url: URL) {
        providePlaceholder(at: url) { _ in
            try? FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - Handling Actions

    @available(iOSApplicationExtension 11.0, *)
    private func modifyItem(withIdentifier identifier: NSFileProviderItemIdentifier,
                            completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void,
                            task: ((inout FileProviderItemConvertible) -> Void)) {
        do {
            guard var object = object(for: identifier) else { throw NSFileProviderError(.noSuchItem) }
            task(&object)

            try coreDataService.viewContext.save()

            let item = object.fileProviderItem

            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: identifier) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: item.parentItemIdentifier) { _ in }

            completionHandler(item, nil)
        } catch {
            completionHandler(nil, NSFileProviderError(.noSuchItem))
        }
    }

    @available(iOSApplicationExtension 11.0, *)
    override func setLastUsedDate(_ lastUsedDate: Date?, forItemIdentifier itemIdentifier: NSFileProviderItemIdentifier,
                                  completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        modifyItem(withIdentifier: itemIdentifier, completionHandler: completionHandler) { object in
            object.itemState.lastUsedAt = lastUsedDate
        }
    }

    @available(iOSApplicationExtension 11.0, *)
    override func setFavoriteRank(_ favoriteRank: NSNumber?, forItemIdentifier itemIdentifier: NSFileProviderItemIdentifier,
                                  completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        modifyItem(withIdentifier: itemIdentifier, completionHandler: completionHandler) { object in
            object.itemState.favoriteRank = favoriteRank?.intValue ?? Int(NSFileProviderFavoriteRankUnranked)
        }
    }

    @available(iOSApplicationExtension 11.0, *)
    override func setTagData(_ tagData: Data?, forItemIdentifier itemIdentifier: NSFileProviderItemIdentifier,
                             completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        modifyItem(withIdentifier: itemIdentifier, completionHandler: completionHandler) { object in
            object.itemState.tagData = tagData
        }
    }
}
