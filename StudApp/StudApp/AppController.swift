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

        NotificationCenter.default.addObserver(self, selector: #selector(currentUserDidChange(notification:)),
                                               name: .currentUserDidChange, object: nil)

        view.backgroundColor = .white

        viewModel = AppViewModel()
        viewModel.update()
    }

    override func viewWillAppear(_ animated: Bool) {
        prepareChildContents(for: User.current)

        super.viewWillAppear(animated)

        tabBar.items?[Tabs.courseList.rawValue].title = "Courses".localized
        tabBar.items?[Tabs.downloadList.rawValue].title = "Downloads".localized
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSignInIfNeeded()
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

    // MARK: - Handling Quick Actions

    func handle(quickAction: QuickActions) -> Bool {
        switch quickAction {
        case .presentCourses:
            selectedIndex = Tabs.courseList.rawValue
        case .presentDownloads:
            selectedIndex = Tabs.downloadList.rawValue
        }

        return true
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        prepareForRoute(using: segue, sender: sender)
    }

    @IBAction
    func unwindToApp(with segue: UIStoryboardSegue) {}

    @IBAction
    func unwindToAppAndSignOut(with segue: UIStoryboardSegue) {
        (segue as? UIStoryboardSegueWithCompletion)?.completion = {
            self.viewModel.signOut()
        }
    }

    func prepareChildContents(for user: User?) {
        courseListController?.prepareContent(for: .courseList(for: user))
        downloadListController?.prepareDependencies(for: .downloadList(for: user))
    }

    func presentSignInIfNeeded() {
        if !viewModel.isSignedIn && presentedViewController == nil {
            performSegue(withRoute: .signIn)
        }
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

    // MARK: - Notifications

    @objc
    private func currentUserDidChange(notification: Notification) {
        prepareChildContents(for: User.current)
        presentSignInIfNeeded()
    }
}
