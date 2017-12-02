//
//  File+StudIp.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension File {
    @discardableResult
    public func download(handler: @escaping ResultHandler<URL>) -> URLSessionTask? {
        let studIpService = ServiceContainer.default[StudIpService.self]
        return studIpService.api.download(.fileContents(forFileId: id), to: documentUrl, handler: handler)
    }

    public func removeDownload() throws {
        state.downloadedAt = nil
        try? FileManager.default.removeItem(at: documentUrl)
        try managedObjectContext?.saveWhenChanged()
    }

    public func updateChildren(in context: NSManagedObjectContext, handler: @escaping ResultHandler<File>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestDecoded(.file(withId: id)) { (result: Result<FileResponse>) in
            File.update(using: result, in: context, handler: handler)

            NSFileProviderManager.default.signalEnumerator(for: self.itemIdentifier) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }
    }
}
