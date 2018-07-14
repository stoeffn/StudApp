//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

import MobileCoreServices

public final class StorageService {

    // MARK: - User Defaults

    lazy var defaults: UserDefaults = {
        guard let defaults = UserDefaults(suiteName: App.groupIdentifier) else {
            fatalError("Cannot initialize user defaults for app group with identifier '\(App.groupIdentifier)'")
        }
        defaults.register(defaults: [
            UserDefaults.Keys.areNotificationsEnabled.rawValue: true
        ])
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

    /// Delete all locally downloaded documents in the downloads and file provider directory.
    ///
    /// - Warning: This method does not reset file states.
    func removeAllDownloads() throws {
        try FileManager.default.removeItem(at: BaseDirectories.downloads.url)
        try FileManager.default.removeItem(at: BaseDirectories.fileProvider.url)
    }
}
