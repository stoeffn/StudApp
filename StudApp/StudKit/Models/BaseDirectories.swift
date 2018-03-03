//
//  BaseDirectories.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public enum BaseDirectories {
    case appGroup

    case downloads

    case fileProvider

    public var url: URL {
        switch self {
        case .appGroup:
            let identifier = App.groupIdentifier
            guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
                fatalError("Cannot create URL for app group directory with identifier '\(identifier)'.")
            }
            return url
        case .downloads:
            return BaseDirectories.appGroup.url.appendingPathComponent("Downloads", isDirectory: true)
        case .fileProvider:
            guard #available(iOSApplicationExtension 11.0, *) else { return BaseDirectories.downloads.url }
            return NSFileProviderManager.default.documentStorageURL
        }
    }

    public func containerUrl(forObjectId objectId: ObjectIdentifier) -> URL {
        return url.appendingPathComponent(objectId.rawValue, isDirectory: true)
    }
}
