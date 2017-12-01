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
    private var coreDataService: CoreDataService!
    private var historyService: HistoryService!

    var window: UIWindow?
}

// MARK: - Application Delegate

extension AppDelegate: UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        ServiceContainer.default.register(providers: StudKitServiceProvider(currentTarget: .app))

        coreDataService = ServiceContainer.default[CoreDataService.self]
        historyService = ServiceContainer.default[HistoryService.self]

        try? historyService.mergeHistory(into: coreDataService.viewContext)
        try? historyService.deleteHistory(mergedInto: Targets.iOSTargets, in: coreDataService.viewContext)

        window?.tintColor = UI.Colors.studBlue

        return true
    }

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
}
