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
        ServiceContainer.default.register(providers: [
            StudKitServiceProvider(currentTarget: .fileProvider),
        ])

        coreDataService = ServiceContainer.default[CoreDataService.self]
        storeService = ServiceContainer.default[StoreService.self]
        studIpService = ServiceContainer.default[StudIpService.self]

        let historyService = ServiceContainer.default[PersistentHistoryService.self]
        try? historyService.mergeHistory(into: coreDataService.viewContext)
        try? historyService.deleteHistory(mergedInto: Targets.iOSTargets, in: coreDataService.viewContext)
    }

    // MARK: - Working with Items and Persistent Identifiers

    func object(for identifier: NSFileProviderItemIdentifier) -> FileProviderItemConvertible? {
        guard
            let objectIdentifier = ObjectIdentifier(rawValue: identifier.rawValue),
            let itemConvertible = try? objectIdentifier.fetch(in: coreDataService.viewContext) as? FileProviderItemConvertible
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

    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
        let objectIdentifier = ObjectIdentifier(rawValue: identifier.rawValue)

        switch objectIdentifier?.entity {
        case .root?:
            return RootItem()
        case .semester?, .course?, .file?:
            guard let object = object(for: identifier) else { throw NSFileProviderError(.noSuchItem) }
            return object.fileProviderItem
        default:
            throw NSFileProviderError(.noSuchItem)
        }
    }

    override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        guard studIpService.isSignedIn else {
            throw NSFileProviderError(.notAuthenticated, userInfo: [
                NSFileProviderError.reasonKey: NSFileProviderError.Reasons.notSignedIn.rawValue,
            ])
        }

        let objectIdentifier = ObjectIdentifier(rawValue: containerItemIdentifier.rawValue)

        switch objectIdentifier?.entity {
        case .workingSet?:
            return WorkingSetEnumerator()
        case .root?:
            guard let user = User.current else { throw NSFileProviderError(.noSuchItem) }
            return CourseEnumerator(user: user)
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
            let object = object(for: itemIdentifier)
        else {
            completionHandler?(NSFileProviderError(.noSuchItem))
            return
        }

        object.provide(at: url, completion: completionHandler)
    }

    override func stopProvidingItem(at url: URL) {
        providePlaceholder(at: url) { _ in
            try? FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - Handling Actions

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

    override func setLastUsedDate(_ lastUsedDate: Date?, forItemIdentifier itemIdentifier: NSFileProviderItemIdentifier,
                                  completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        modifyItem(withIdentifier: itemIdentifier, completionHandler: completionHandler) { object in
            object.itemState.lastUsedAt = lastUsedDate
        }
    }

    override func setFavoriteRank(_ favoriteRank: NSNumber?, forItemIdentifier itemIdentifier: NSFileProviderItemIdentifier,
                                  completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        modifyItem(withIdentifier: itemIdentifier, completionHandler: completionHandler) { object in
            object.itemState.favoriteRank = favoriteRank?.intValue ?? Int(NSFileProviderFavoriteRankUnranked)
        }
    }

    override func setTagData(_ tagData: Data?, forItemIdentifier itemIdentifier: NSFileProviderItemIdentifier,
                             completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        modifyItem(withIdentifier: itemIdentifier, completionHandler: completionHandler) { object in
            object.itemState.tagData = tagData
        }
    }
}
