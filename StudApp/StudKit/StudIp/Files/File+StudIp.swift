//
//  File+StudIp.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension File {
    public func updateChildren(in context: NSManagedObjectContext, handler: @escaping ResultHandler<File>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestDecoded(.file(withId: id)) { (result: Result<FileResponse>) in
            File.update(using: result, in: context, handler: handler)

            if #available(iOSApplicationExtension 11.0, *) {
                NSFileProviderManager.default.signalEnumerator(for: self.itemIdentifier) { _ in }
                NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
            }
        }
    }

    @discardableResult
    public func download(handler: @escaping ResultHandler<URL>) -> Progress? {
        guard !state.isMostRecentVersionDownloaded else {
            handler(.success(documentUrl(inProviderDirectory: true)))
            return nil
        }

        let downloadDate = Date()
        state.isDownloading = true

        let studIpService = ServiceContainer.default[StudIpService.self]
        let task = studIpService.api.download(.fileContents(forFileId: id), to: documentUrl(), startsResumed: false) { result in
            self.state.isDownloading = false

            guard result.isSuccess else {
                return handler(.failure(result.error ?? "Something went wrong downloading this document".localized))
            }

            self.state.downloadedAt = downloadDate
            try? self.managedObjectContext?.saveWhenChanged()

            return handler(.success(self.documentUrl(inProviderDirectory: true)))
        }

        guard let downloadTask = task else { return nil }

        if #available(iOSApplicationExtension 11.0, *) {
            NSFileProviderManager.default.register(downloadTask, forItemWithIdentifier: itemIdentifier) { _ in
                downloadTask.resume()
            }
        } else {
            downloadTask.resume()
        }

        return nil
    }

    public func removeDownload() throws {
        state.downloadedAt = nil
        try? FileManager.default.removeItem(at: documentUrl())
        try managedObjectContext?.saveWhenChanged()
    }
}
