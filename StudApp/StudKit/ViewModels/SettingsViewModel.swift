//
//  SettingsViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 24.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class SettingsViewModel {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let studIpService = ServiceContainer.default[StudIpService.self]
    private let storageService = ServiceContainer.default[StorageService.self]

    public init() {}

    /// The total combined file sizes in the downloaded documents directory.
    public var sizeOfDownloadsDirectory: Int? {
        return FileManager.default
            .enumerator(at: BaseDirectories.downloads.url, includingPropertiesForKeys: [.fileSizeKey], options: [])?
            .flatMap { $0 as? URL }
            .flatMap { try? $0.resourceValues(forKeys: [.fileSizeKey]) }
            .flatMap { $0.fileSize }
            .reduce(0, +)
    }

    /// Delete all locally downloaded documents in the downloads and file provider directory.
    public func removeAllDownloads() throws {
        try storageService.removeAllDownloads()

        try File.fetch(in: coreDataService.viewContext).forEach { $0.state.downloadedAt = nil }
        try coreDataService.viewContext.saveWhenChanged()
    }

    /// Sign user out of this app and the API.
    public func signOut() {
        studIpService.signOut()
    }
}
