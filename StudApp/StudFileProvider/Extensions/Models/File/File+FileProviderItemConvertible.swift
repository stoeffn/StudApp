//
//  File+FileProviderItemConvertible.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import StudKit

extension File: FileProviderItemConvertible {
    public var itemState: FileProviderItemConvertibleState {
        return state
    }

    public var fileProviderItem: NSFileProviderItem {
        return FileItem(from: self)
    }

    public func provide(at url: URL, completion: ((Error?) -> Void)?) {
        guard !isFolder else {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                completion?(nil)
            } catch {
                completion?(error)
            }
            return
        }

        download { result in
            guard result.isSuccess else {
                if #available(iOSApplicationExtension 11.0, *) {
                    completion?(NSFileProviderError(.serverUnreachable))
                } else {
                    completion?(FileProviderExtension.Errors.serverUnreachable)
                }
                return
            }

            do {
                try? FileManager.default.removeItem(at: url)
                try FileManager.default.createIntermediateDirectories(forFileAt: url)
                try FileManager.default.copyItem(at: self.localUrl(in: .downloads), to: url)
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }
}
