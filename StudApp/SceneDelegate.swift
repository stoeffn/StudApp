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

    var window: UIWindow?

    func sceneWillEnterForeground(_ scene: UIScene) {
        try? historyService.mergeHistory(into: coreDataService.viewContext)
        try? historyService.deleteHistory(mergedInto: Targets.iOSTargets, in: coreDataService.viewContext)

        reachabilityService.update()

        (window?.rootViewController as? AppController)?.updateViewModel()
    }
}
