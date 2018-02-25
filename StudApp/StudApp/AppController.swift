//
//  AppController.swift
//  StudApp
//
//  Created by Steffen Ryll on 23.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import SafariServices
import StudKit
import StudKitUI

final class AppController: UITabBarController {
    private var viewModel: AppViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = AppViewModel()

        view.backgroundColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
        courseListController?.prepareDependencies(for: .courseList(for: User.current))
        downloadListController?.prepareDependencies(for: .downloadList(for: User.current))

        super.viewWillAppear(animated)

        tabBar.items?[Tabs.courseList.rawValue].title = "Courses".localized
        tabBar.items?[Tabs.downloadList.rawValue].title = "Downloads".localized
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !viewModel.isSignedIn {
            performSegue(withRoute: .signIn)
        }
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

    @IBAction
    func unwindToApp(with _: UIStoryboardSegue) {
        if !viewModel.isSignedIn {
            performSegue(withRoute: .signIn)
        }
    }

    @IBAction
    func unwindToAppAndSignOut(with _: UIStoryboardSegue) {
        viewModel.signOut()
    }

    // MARK: - User Interface

    private enum Tabs: Int {
        case courseList, downloadList
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

    var downloadListController: DownloadListController? {
        return viewControllers?
            .flatMap { $0 as? UINavigationController }
            .flatMap { $0.viewControllers.first }
            .flatMap { $0 as? DownloadListController }
            .first
    }

    func controllerForMore(at barButtonItem: UIBarButtonItem? = nil) -> UIViewController {
        guard let currentUser = User.current else { fatalError() }

        let actions = [
            UIAlertAction(title: "About".localized, style: .default) { _ in
                self.performSegue(withRoute: .about)
            },
            UIAlertAction(title: "Help".localized, style: .default) { _ in
                guard let controller = self.controllerForHelp() else { return }
                self.present(controller, animated: true, completion: nil)
            },
            UIAlertAction(title: "Settings".localized, style: .default) { _ in
                self.performSegue(withRoute: .settings)
            },
            UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil),
        ]

        let title = "Signed in as %@".localized(currentUser.nameComponents.formatted(style: .long))
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        controller.popoverPresentationController?.barButtonItem = barButtonItem
        actions.forEach(controller.addAction)
        return controller
    }

    private func controllerForHelp() -> UIViewController? {
        let controller = SFSafariViewController(url: App.Urls.help)
        controller.preferredControlTintColor = UI.Colors.tint
        return controller
    }

    // MARK: - User Interaction

    @IBAction
    func userButtonTapped(_ sender: Any) {
        present(controllerForMore(at: sender as? UIBarButtonItem), animated: true, completion: nil)
    }
}
