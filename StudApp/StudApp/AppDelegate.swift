//
//  AppDelegate.swift
//  StudApp
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

@UIApplicationMain
final class AppDelegate: UIResponder {
    private let openUrl = { UIApplication.shared.open($0, options: [:], completionHandler: $1) }

    private var coreDataService: CoreDataService!
    private var historyService: HistoryService!
    private var studIpService: StudIpService!

    var window: UIWindow?
}

// MARK: - Application Delegate

extension AppDelegate: UIApplicationDelegate {
    // MARK: Initializing the App

    func application(_: UIApplication, willFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
        ServiceContainer.default.register(providers: StudKitServiceProvider(currentTarget: .app, openUrl: openUrl))

        coreDataService = ServiceContainer.default[CoreDataService.self]
        historyService = ServiceContainer.default[HistoryService.self]
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
        try? coreDataService.viewContext.saveWhenChanged()
    }

    func applicationWillEnterForeground(_: UIApplication) {
        try? historyService.mergeHistory(into: coreDataService.viewContext)
        try? historyService.deleteHistory(mergedInto: Targets.iOSTargets, in: coreDataService.viewContext)
    }

    func applicationWillTerminate(_: UIApplication) {
        try? coreDataService.viewContext.saveWhenChanged()
    }

    // MARK: Managing App State Restoration

    func application(_: UIApplication, shouldSaveApplicationState _: NSCoder) -> Bool {
        return studIpService.isSignedIn
    }

    func application(_: UIApplication, shouldRestoreApplicationState _: NSCoder) -> Bool {
        return studIpService.isSignedIn
    }

    // MARK: Continuing User Activity and Handling Quick Actions

    func application(_: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler _: @escaping ([Any]?) -> Void) -> Bool {
        window?.rootViewController?.restoreUserActivityState(userActivity)
        return true
    }

    // MARK: Opening a URL-Specified Resource

    func application(_: UIApplication, open _: URL, options _: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return true
    }
}
