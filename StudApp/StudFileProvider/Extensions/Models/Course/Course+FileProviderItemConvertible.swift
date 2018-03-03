//
//  Course+FileProviderItemConvertible.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import StudKit

extension Course: FileProviderItemConvertible {
    public var itemState: FileProviderItemConvertibleState {
        return state
    }

    public var fileProviderItem: NSFileProviderItem {
        return CourseItem(from: self)
    }

    public func localUrl(in directory: BaseDirectories) -> URL {
        return directory.containerUrl(forObjectId: objectIdentifier)
            .appendingPathComponent(title.sanitizedAsFilename, isDirectory: true)
    }

    public func provide(at url: URL, completion: ((Error?) -> Void)?) {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            completion?(nil)
        } catch {
            completion?(error)
        }
    }
}
