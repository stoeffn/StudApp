//
//  TabsController.swift
//  StudApp
//
//  Created by Steffen Ryll on 07.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import SafariServices
import StudKit
import StudKitUI

final class TabsController: UITabBarController, Routable {
    private var user: User!

    // MARK: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBar.items?[Tabs.downloadList.rawValue].title = "Downloads".localized
        tabBar.items?[Tabs.courseList.rawValue].title = "Courses".localized
    }

    // MARK: - Supporting User Activities

    override func restoreUserActivityState(_ activity: NSUserActivity) {
        switch activity.objectIdentifier?.entity {
        case .file?:
            selectedIndex = Tabs.downloadList.rawValue
            downloadListController?.restoreUserActivityState(activity)
        case .course?:
            selectedIndex = Tabs.courseList.rawValue
            courseListController?.restoreUserActivityState(activity)
        default:
            let title = "Something went wrong continuing your activity.".localized
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
            return present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        prepareForRoute(using: segue, sender: sender)
    }

    func prepareDependencies(for route: Routes) {
        guard case let .app(user) = route else { fatalError() }
        self.user = user
    }

    // MARK: - User Interface

    private enum Tabs: Int {
        case courseList, downloadList
    }

    var downloadListController: DownloadListController? {
        return viewControllers?
            .flatMap { $0 as? UINavigationController }
            .flatMap { $0.viewControllers.first }
            .flatMap { $0 as? DownloadListController }
            .first
    }

    var courseListController: CourseListController? {
        return viewControllers?
            .flatMap { $0 as? UISplitViewController }
            .flatMap { $0.viewControllers.first }
            .flatMap { $0 as? UINavigationController }
            .flatMap { $0.viewControllers.first }
            .flatMap { $0 as? CourseListController }
            .first
    }

    // MARK: - User Interaction

    @IBAction
    func userButtonTapped(_ sender: Any) {
        func showAboutView(_: UIAlertAction) {
            let route = Routes.about {
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }
            performSegue(withRoute: route)
        }

        func showHelpView(_: UIAlertAction) {
            guard let url = App.Links.help else { return }
            let controller = SFSafariViewController(url: url)
            controller.preferredControlTintColor = UI.Colors.tint
            present(controller, animated: true, completion: nil)
        }

        func showSettingsView(_: UIAlertAction) {
            performSegue(withRoute: .settings { _ in fatalError("TODO") })
        }

        guard let currentUser = User.current else { return }
        let barButtonItem = sender as? UIBarButtonItem
        let title = "Signed in as %@".localized(currentUser.nameComponents.formatted(style: .long))

        let controller = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        controller.popoverPresentationController?.barButtonItem = barButtonItem
        controller.addAction(UIAlertAction(title: "About".localized, style: .default, handler: showAboutView))
        controller.addAction(UIAlertAction(title: "Help".localized, style: .default, handler: showHelpView))
        controller.addAction(UIAlertAction(title: "Settings".localized, style: .default, handler: showSettingsView))
        controller.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
}