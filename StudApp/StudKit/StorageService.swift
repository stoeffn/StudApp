//
//  StorageService.swift
//  StudKit
//
//  Created by Steffen Ryll on 29.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class StorageService {
    lazy var defaults: UserDefaults = {
        let identifier = StudKitServiceProvider.appGroupIdentifier
        guard let defaults = UserDefaults(suiteName: identifier) else {
            fatalError("Cannot initialize user defaults for app group with identifier '\(identifier)'")
        }
        return defaults
    }()

    lazy var documentsUrl: URL = {
        let identifier = StudKitServiceProvider.appGroupIdentifier
        guard let appGroupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
            fatalError("Cannot create URL for app group directory with identifier '\(identifier)'.")
        }
        return appGroupUrl.appendingPathComponent("Dcouments", isDirectory: true)
    }()

    func removeAllDocuments() throws {
        try FileManager.default.removeItem(at: documentsUrl)
    }
}
