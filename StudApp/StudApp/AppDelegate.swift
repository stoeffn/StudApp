//
//  AppDelegate.swift
//  StudApp
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit
import StudKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    private var coreDataService: CoreDataService!
    private var historyService: HistoryService!

    var window: UIWindow?

    // MARK: - Life Cycle

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        ServiceContainer.default.register(providers: StudKitServiceProvider(target: .app))
        coreDataService = ServiceContainer.default[CoreDataService.self]
        historyService = ServiceContainer.default[HistoryService.self]

        try? historyService.mergeHistory(into: coreDataService.viewContext)
        try? historyService.deleteMergedHistory(in: Targets.iOSTargets, in: coreDataService.viewContext)

        return true
    }

    func applicationDidEnterBackground(_: UIApplication) {
        try? coreDataService.viewContext.saveWhenChanged()
    }

    func applicationWillEnterForeground(_: UIApplication) {
        try? historyService.mergeHistory(into: coreDataService.viewContext)
        try? historyService.deleteMergedHistory(in: Targets.iOSTargets, in: coreDataService.viewContext)
        NotificationCenter.default.post(name: HistoryService.MergeNotificationName, object: nil)
    }

    func applicationWillTerminate(_: UIApplication) {
        try? coreDataService.viewContext.saveWhenChanged()
    }
}
