//
//  AppDelegate.swift
//  StudApp
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit
import StudKitUI

@UIApplicationMain
final class AppDelegate: UIResponder {
    private var contextService: ContextService!
    private var coreDataService: CoreDataService!
    private var historyService: PersistentHistoryService!
    private var studIpService: StudIpService!

    var window: UIWindow?
}

// MARK: - Application Delegate

extension AppDelegate: UIApplicationDelegate {

    // MARK: Initializing the App

    func application(_: UIApplication, willFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
        ServiceContainer.default.register(providers: [
            StudKitServiceProvider(currentTarget: .app, isRunningUiTests: isRunningUiTests, openUrl: open,
                                   preferredContentSizeCategory: preferredContentSizeCategory),
            StudKitUIServiceProvider(),
        ])

        contextService = ServiceContainer.default[ContextService.self]
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
    }

    func applicationWillTerminate(_: UIApplication) {
        try? coreDataService.viewContext.saveAndWaitWhenChanged()
    }

    // MARK: Managing App State Restoration

    func application(_: UIApplication, shouldSaveApplicationState _: NSCoder) -> Bool {
        return studIpService.isSignedIn && !contextService.isRunningUiTests
    }

    func application(_: UIApplication, shouldRestoreApplicationState _: NSCoder) -> Bool {
        return studIpService.isSignedIn && !contextService.isRunningUiTests
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

    // MARK: - Helpers

    private static let uiTestsProcessArgument = "uiTest"

    private var isRunningUiTests: Bool {
        return ProcessInfo.processInfo.arguments.contains(AppDelegate.uiTestsProcessArgument)
    }

    private func open(url: URL, completion: ((Bool) -> Void)?) {
        return UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }

    private func preferredContentSizeCategory() -> UIContentSizeCategory {
        return UIApplication.shared.preferredContentSizeCategory
    }
}
