//
//  StorageService.swift
//  StudKit
//
//  Created by Steffen Ryll on 29.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import MobileCoreServices

public final class StorageService {
    // MARK: - User Defaults

    lazy var defaults: UserDefaults = {
        guard let defaults = UserDefaults(suiteName: App.groupIdentifier) else {
            fatalError("Cannot initialize user defaults for app group with identifier '\(App.groupIdentifier)'")
        }
        return defaults
    }()

    // MARK: - Handling Uniform Type Identifiers

    func typeIdentifier(forFileExtension fileExtension: String) -> String? {
        return UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)?
            .takeRetainedValue() as String?
    }

    func fileExtension(forTypeIdentifier typeIdentifier: String) -> String? {
        return UTTypeCopyPreferredTagWithClass(typeIdentifier as CFString, kUTTagClassFilenameExtension)?
            .takeRetainedValue() as String?
    }

    // MARK: - Managing Downloads and Documents

    func removeAllDownloads() throws {
        try FileManager.default.removeItem(at: BaseDirectories.downloads.url)
    }
}
