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
    public func updateChildFiles(in context: NSManagedObjectContext, completion: @escaping ResultHandler<File>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestDecoded(.folder(withId: id)) { (result: Result<FolderResponse>) in
            let result = result.map { response -> File in
                guard let folder = context.object(with: self.objectID) as? File else { fatalError() }
                return try File.updateFolder(from: response, course: folder.course, in: context)
            }
            completion(result)
        }
    }

    static func updateFolder(from response: FolderResponse, course: Course, in context: NSManagedObjectContext) throws -> File {
        let folder = try response.coreDataObject(course: course, in: context)

        CSSearchableIndex.default().indexSearchableItems(folder.searchableChildItems) { _ in }

        if #available(iOSApplicationExtension 11.0, *) {
            let itemIdentifier = NSFileProviderItemIdentifier(rawValue: folder.objectIdentifier.rawValue)
            NSFileProviderManager.default.signalEnumerator(for: itemIdentifier) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }

        return folder
    }

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
        state.downloadedAt = nil
        try? FileManager.default.removeItem(at: localUrl(in: .downloads))
        try? FileManager.default.removeItem(at: localUrl(in: .fileProvider))
        try managedObjectContext?.saveAndWaitWhenChanged()
    }

    public var url: URL? {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard
            let baseUrl = studIpService.api.baseUrl?.deletingLastPathComponent(),
            let url = URL(string: "\(baseUrl)/download/force_download/0/\(id)/\(name)")
        else { return nil }
        return url
    }
}
