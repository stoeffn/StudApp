//
//  StorageService.swift
//  StudKit
//
//  Created by Steffen Ryll on 29.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class StorageService {
    lazy var defaults: UserDefaults = {
        guard let defaults = UserDefaults(suiteName: App.groupIdentifier) else {
            fatalError("Cannot initialize user defaults for app group with identifier '\(App.groupIdentifier)'")
        }
        return defaults
    }()

    lazy var appGroupUrl: URL = {
        let identifier = App.groupIdentifier
        guard let appGroupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
            fatalError("Cannot create URL for app group directory with identifier '\(identifier)'.")
        }
        return appGroupUrl
    }()

    lazy var documentsUrl = appGroupUrl.appendingPathComponent("Documents", isDirectory: true)

    lazy var fileProviderDocumentsUrl: URL = {
        guard #available(iOSApplicationExtension 11.0, *) else {
            return appGroupUrl.appendingPathComponent("File Provider Storage", isDirectory: true)
        }
        return NSFileProviderManager.default.documentStorageURL
    }()

    func removeAllDocuments() throws {
        try FileManager.default.removeItem(at: documentsUrl)
    }
}
