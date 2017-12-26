//
//  CourseListSplitController.swift
//  StudApp
//
//  Created by Steffen Ryll on 23.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

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
