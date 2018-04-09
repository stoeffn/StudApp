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

import StudKit
import StudKitUI

@UIApplicationMain
final class AppDelegate: UIResponder {
    private var coreDataService: CoreDataService!
    private var historyService: PersistentHistoryService!
    private var studIpService: StudIpService!

    var window: UIWindow?
}

// MARK: - Application Delegate

extension AppDelegate: UIApplicationDelegate {

    // MARK: Initializing the App

    func application(_: UIApplication, willFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
        let context = Targets.Context(currentTarget: .app, extensionContext: nil, openUrl: UIApplication.shared.open,
                                      preferredContentSizeCategory: { UIApplication.shared.preferredContentSizeCategory })

        ServiceContainer.default.register(providers: [
            StudKitServiceProvider(context: context),
            StudKitUIServiceProvider()
        ])

        coreDataService = ServiceContainer.default[CoreDataService.self]
        historyService = ServiceContainer.default[PersistentHistoryService.self]
        studIpService = ServiceContainer.default[StudIpService.self]

        return true
    }

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        try? historyService.mergeHistory(into: coreDataService.viewContext)
        try? historyService.deleteHistory(mergedInto: Targets.iOSTargets, in: coreDataService.viewContext)

        window?.tintColor = UI.Colors.tint

        addCustomMenuItems(to: UIMenuController.shared)

        return true
    }

    // MARK: Responding to App State Changes and System Events

    func applicationDidEnterBackground(_: UIApplication) {
        try? coreDataService.viewContext.saveAndWaitWhenChanged()
    }

    func applicationWillEnterForeground(_: UIApplication) {
        try? historyService.mergeHistory(into: coreDataService.viewContext)
        try? historyService.deleteHistory(mergedInto: Targets.iOSTargets, in: coreDataService.viewContext)

        (window?.rootViewController as? AppController)?.updateViewModel()
    }

    func applicationWillTerminate(_: UIApplication) {
        try? coreDataService.viewContext.saveAndWaitWhenChanged()
    }

    // MARK: Managing App State Restoration

    func application(_: UIApplication, shouldSaveApplicationState _: NSCoder) -> Bool {
        return studIpService.isSignedIn && Distributions.current != .uiTest
    }

    func application(_: UIApplication, shouldRestoreApplicationState _: NSCoder) -> Bool {
        return studIpService.isSignedIn && Distributions.current != .uiTest
    }

    // MARK: Continuing User Activity and Handling Quick Actions

    func application(_: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler _: @escaping ([Any]?) -> Void) -> Bool {
        window?.rootViewController?.restoreUserActivityState(userActivity)
        return true
    }

    func application(_: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        guard
            let quickAction = QuickActions(fromShortcutItemType: shortcutItem.type),
            let appController = window?.rootViewController as? AppController
        else { return completionHandler(false) }
        completionHandler(appController.handle(quickAction: quickAction))
    }

    // MARK: Opening a URL-Specified Resource

    func application(_: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        guard
            let sourceApplication = options[.sourceApplication] as? String,
            sourceApplication == safariServicesBundleIdentifier
        else { return false }

        NotificationCenter.default.post(name: .safariViewControllerDidLoadAppUrl, object: self, userInfo: [
            Notification.Name.safariViewControllerDidLoadAppUrlKey: url,
        ])

        return true
    }
}
