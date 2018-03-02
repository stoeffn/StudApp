//
//  File+StudIp.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import CoreSpotlight

extension File {

    // MARK: - Updating Children

    public func updateChildFiles(completion: @escaping ResultHandler<Set<File>>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        update(lastUpdatedAt: \.state.childFilesUpdatedAt, expiresAfter: 60 * 10, completion: completion) { updaterCompletion in
            studIpService.api.requestDecoded(.folder(withId: self.id)) { (result: Result<FolderResponse>) in
                context.perform {
                    updaterCompletion(result.map { try self.updateChildFiles(from: $0) })
                }
            }
        }
    }

    func updateChildFiles(from response: FolderResponse) throws -> Set<File> {
        guard let context = managedObjectContext else { fatalError() }

        let folder = try response.coreDataObject(course: course, in: context)

        let searchableItems = folder.children
            .filter { !$0.isFolder }
            .map { $0.searchableItem }
        CSSearchableIndex.default().indexSearchableItems(searchableItems) { _ in }

        if #available(iOSApplicationExtension 11.0, *) {
            let itemIdentifier = NSFileProviderItemIdentifier(rawValue: folder.objectIdentifier.rawValue)
            NSFileProviderManager.default.signalEnumerator(for: itemIdentifier) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }

        return folder.children
    }

    // MARK: - Managing Downloads

    @discardableResult
    public func download(completion: @escaping ResultHandler<URL>) -> Progress? {
        guard !state.isMostRecentVersionDownloaded else {
            completion(.success(localUrl(in: .fileProvider)))
            return nil
        }

        try? FileManager.default.createIntermediateDirectories(forFileAt: localUrl(in: .downloads))
        try? FileManager.default.createIntermediateDirectories(forFileAt: localUrl(in: .fileProvider))

        let downloadDate = Date()
        state.isDownloading = true

        let studIpService = ServiceContainer.default[StudIpService.self]
        let destination = localUrl(in: .downloads)
        let task = studIpService.api.download(.fileContents(forFileId: id), to: destination, startsResumed: false) { result in
            self.state.isDownloading = false

            guard result.isSuccess else {
                return completion(.failure(result.error))
            }

            self.downloadedBy.formUnion([User.current].flatMap { $0 })
            self.state.downloadedAt = downloadDate
            try? self.managedObjectContext?.saveAndWaitWhenChanged()

            return completion(.success(self.localUrl(in: .fileProvider)))
        }

        guard let downloadTask = task else { return nil }

        if #available(iOSApplicationExtension 11.0, *) {
            let itemIdentifier = NSFileProviderItemIdentifier(rawValue: objectIdentifier.rawValue)
            NSFileProviderManager.default.register(downloadTask, forItemWithIdentifier: itemIdentifier) { _ in
                downloadTask.resume()
            }
            return downloadTask.progress
        }

        downloadTask.resume()
        return nil
    }

    public func removeDownload() throws {
        downloadedBy.subtract([User.current].flatMap { $0 })

        guard downloadedBy.isEmpty else { return }

        state.downloadedAt = nil
        try? FileManager.default.removeItem(at: localUrl(in: .downloads))
        try? FileManager.default.removeItem(at: localUrl(in: .fileProvider))
        try managedObjectContext?.saveAndWaitWhenChanged()
    }

    // MARK: - Managing Metadata

    public var url: URL? {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard
            let baseUrl = studIpService.api.baseUrl?.deletingLastPathComponent(),
            let url = URL(string: "\(baseUrl)/download/force_download/0/\(id)/\(name)")
        else { return nil }
        return url
    }
}
