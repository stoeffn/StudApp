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

public final class NotificationService {
    private let storageService = ServiceContainer.default[StorageService.self]
    private let studIpService = ServiceContainer.default[StudIpService.self]

    // MARK: - Life Cycle

    public init() {
        deviceToken = storageService.defaults.deviceToken
    }

    // MARK: - Configuration

    public var deviceToken: Data? {
        didSet {
            storageService.defaults.deviceToken = deviceToken
            updateOrCreateHooks()
        }
    }

    var apnsUrl: URL {
        switch Distributions.current {
        case .debug: return URL(string: "https://api.development.push.apple.com:443")!
        default: return URL(string: "https://api.push.apple.com:443")!
        }
    }

    func apnsUrl(forDeviceToken deviceToken: Data) -> URL {
        return apnsUrl
            .appendingPathComponent("3", isDirectory: true)
            .appendingPathComponent("device", isDirectory: true)
            .appendingPathComponent(deviceToken.hex, isDirectory: true)
    }

    public func requestAuthorization(options: UNAuthorizationOptions, completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (_, _) in
            DispatchQueue.main.async { completion() }
        }
    }

    // MARK: - Hooks

    var documentHook: Hook? {
        guard let deviceToken = deviceToken else { return nil }

        let id = "\(App.id)-files"
        let json = """
            "aps": {
                "content-available": 1,
                "alert": "Hello, World!"
            },
            "type": "\(id)"
        """
        let thenSettings = Hook.ThenSettings(url: apnsUrl(forDeviceToken: deviceToken), json: json)
        return Hook(id: id, title: "StudApp: Files", ifType: .documentChange, thenSettings: thenSettings)
    }

    var hooks: [Hook] {
        return [documentHook].compactMap { $0 }
    }

    // MARK: - Updating Hooks

    func updateOrCreate(hook: Hook, completion: @escaping ResultHandler<Hook>) {
        studIpService.api.requestDecoded(.updateOrCreateHook(hook)) { (result: Result<Hook>) in completion(result) }
    }

    func updateOrCreateHooks() {
        hooks.forEach { updateOrCreate(hook: $0) { _ in } }
    }

    // MARK: - Options

    public var silentNotificationAuthorizationsOptions: UNAuthorizationOptions {
        guard #available(iOSApplicationExtension 12.0, *) else { return [] }
        return [.alert, .sound, .badge, .provisional, .providesAppNotificationSettings]
    }

    public var userNotificationAuthorizationsOptions: UNAuthorizationOptions {
        guard #available(iOSApplicationExtension 12.0, *) else { return [.alert, .sound, .badge] }
        return [.alert, .sound, .badge, .providesAppNotificationSettings]
    }
}
