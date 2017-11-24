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
    public func download(handler: @escaping ResultHandler<URL>) -> URLSessionTask {
        let studIp = ServiceContainer.default[StudIpService.self]
        return studIp.api.download(.fileContents(forFileId: id), to: localUrl, handler: handler)
    }

    public func removeDownload() throws {
        state.downloadDate = nil
        try FileManager.default.removeItem(at: localUrl)
        try managedObjectContext?.saveWhenChanged()
    }

    public func updateChildren(in context: NSManagedObjectContext, handler: @escaping ResultHandler<File>) {
        let studIp = ServiceContainer.default[StudIpService.self]
        studIp.api.requestDecoded(.file(withId: id)) { (result: Result<FileResponse>) in
            File.update(using: result, in: context, handler: handler)

            NSFileProviderManager.default.signalEnumerator(for: self.itemIdentifier) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }
    }
}
