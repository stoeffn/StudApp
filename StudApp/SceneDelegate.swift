//
//  StudApp—Stud.IP to Go
//  Copyright © 2019, Steffen Ryll
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

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let historyService = ServiceContainer.default[PersistentHistoryService.self]
    private let reachabilityService = ServiceContainer.default[ReachabilityService.self]

    #if targetEnvironment(macCatalyst)
    static let toolbarGroupIdentifier = NSToolbarItem.Identifier(rawValue: "Group")
    #endif

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        #if targetEnvironment(macCatalyst)
        let toolbar = NSToolbar(identifier: "Toolbar")
        toolbar.delegate = self
        toolbar.centeredItemIdentifier = SceneDelegate.toolbarGroupIdentifier

        windowScene.titlebar?.toolbar = toolbar
        windowScene.titlebar?.titleVisibility = .hidden

        let rootViewController = window?.rootViewController as? UITabBarController
        rootViewController?.tabBar.isHidden = true
        #endif
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        try? historyService.mergeHistory(into: coreDataService.viewContext)
        try? historyService.deleteHistory(mergedInto: Targets.iOSTargets, in: coreDataService.viewContext)

        reachabilityService.update()

        let rootViewController = window?.rootViewController as? AppController
        rootViewController?.updateViewModel()
    }
}

#if targetEnvironment(macCatalyst)
extension SceneDelegate: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        guard itemIdentifier == SceneDelegate.toolbarGroupIdentifier else { return nil }

        let items = [Strings.Terms.courses, Strings.Terms.events, Strings.Terms.downloads].map { $0.localized }
        let group = NSToolbarItemGroup(itemIdentifier: SceneDelegate.toolbarGroupIdentifier, titles: items,
                                       selectionMode: .selectOne, labels: items, target: self,
                                       action: #selector(toolbarGroupSelectionDidChange))
        group.setSelected(true, at: 0)
        return group
    }

    @objc
    func toolbarGroupSelectionDidChange(sender: NSToolbarItemGroup) {
        let rootViewController = window?.rootViewController as? UITabBarController
        rootViewController?.selectedIndex = sender.selectedIndex
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [SceneDelegate.toolbarGroupIdentifier, NSToolbarItem.Identifier.flexibleSpace]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
}
#endif
