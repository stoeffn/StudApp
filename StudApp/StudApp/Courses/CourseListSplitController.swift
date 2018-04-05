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

import StudKitUI

final class CourseListSplitController: UISplitViewController {

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        preferredDisplayMode = .allVisible

        view.backgroundColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.backgroundColor = UI.Colors.greyText

        if !isCollapsed && viewControllers.count == 1 {
            performSegue(withRoute: .emptyCourse)
        }
    }
}

// MARK: - Split View Controller Delegate

extension CourseListSplitController: UISplitViewControllerDelegate {
    func splitViewController(_: UISplitViewController, collapseSecondary secondaryViewController: UIViewController,
                             onto _: UIViewController) -> Bool {
        return secondaryViewController is EmptyCourseController
    }

    public func splitViewController(_: UISplitViewController,
                                    separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        guard
            let navigationController = primaryViewController as? UINavigationController,
            navigationController.topViewController is CourseListController
        else { return nil }
        return Routes.emptyCourse.instantiateViewController()
    }
}
