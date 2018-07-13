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

import UserNotifications

public final class SettingsViewModel: NSObject {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let notificationService = ServiceContainer.default[NotificationService.self]
    private let studIpService = ServiceContainer.default[StudIpService.self]
    private let storageService = ServiceContainer.default[StorageService.self]

    override public init() {
        super.init()
        self.areNotificationsEnabled = storageService.defaults.areNotificationsEnabled
    }

    // MARK: - Downloads

    /// The total combined file sizes in the downloaded documents directory.
    public var sizeOfDownloadsDirectory: Int? {
        return FileManager.default
            .enumerator(at: BaseDirectories.downloads.url, includingPropertiesForKeys: [.fileSizeKey], options: [])?
            .compactMap { $0 as? URL }
            .compactMap { try? $0.resourceValues(forKeys: [.fileSizeKey]) }
            .compactMap { $0.fileSize }
            .reduce(0, +)
    }

    /// Delete all locally downloaded documents in the downloads and file provider directory.
    public func removeAllDownloads() throws {
        try storageService.removeAllDownloads()
        try File.fetch(in: coreDataService.viewContext).forEach { file in
            file.downloadedBy.removeAll()
            file.state.downloadedAt = nil
        }
        try coreDataService.viewContext.saveAndWaitWhenChanged()
    }

    // MARK: - Notifications

    @objc public private(set) dynamic var areNotificationsAllowed = false

    @objc public dynamic var areNotificationsEnabled = false {
        didSet {
            storageService.defaults.areNotificationsEnabled = areNotificationsEnabled

            guard areNotificationsAllowed else { return areNotificationsEnabled = false }
            guard areNotificationsEnabled else { return }

            notificationService.requestAuthorization(options: notificationService.silentNotificationAuthorizationsOptions) {
                self.updateNotificationSettings()
            }
        }
    }

    @objc public private(set) dynamic var areNotificationsProvisional = false

    public func updateNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.areNotificationsAllowed = settings.authorizationStatus != .denied
                self.areNotificationsEnabled = self.areNotificationsEnabled && self.areNotificationsAllowed
                guard #available(iOS 12, *) else { return }
                self.areNotificationsProvisional = settings.authorizationStatus == .provisional
            }
        }
    }

    public func requestProminentDelivery() {
        notificationService.requestAuthorization(options: notificationService.userNotificationAuthorizationsOptions) {
            self.updateNotificationSettings()
        }
    }
}
