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
    private var coreDataService: CoreDataService?

    var window: UIWindow?
    
    // MARK: - Life Cycle

    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        ServiceContainer.default.register(providers: StudKitServiceProvider())
        coreDataService = ServiceContainer.default[CoreDataService.self]
        return true
    }

    func applicationDidEnterBackground(_: UIApplication) {
        try? coreDataService?.viewContext.saveWhenChanged()
    }

    func applicationWillTerminate(_: UIApplication) {
        try? coreDataService?.viewContext.saveWhenChanged()
    }
}
