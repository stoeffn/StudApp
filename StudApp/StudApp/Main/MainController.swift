//
//  MainController.swift
//  StudApp
//
//  Created by Steffen Ryll on 07.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class MainController: UITabBarController {
    private var viewModel: MainViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = MainViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBar.items?[Tabs.downloadList.rawValue].title = "Downloads".localized
        tabBar.items?[Tabs.courseList.rawValue].title = "Courses".localized

        viewModel.updateCurrentUser()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !viewModel.isSignedIn {
            performSegue(withRoute: .signIn)
        }
    }

    // MARK: - Supporting User Activities

    override func restoreUserActivityState(_ activity: NSUserActivity) {
        switch activity.activityType {
        case UserActivities.fileIdentifier:
            selectedIndex = Tabs.downloadList.rawValue
            downloadListController?.restoreUserActivityState(activity)
        case UserActivities.courseIdentifier:
            selectedIndex = Tabs.courseList.rawValue
            courseListController?.restoreUserActivityState(activity)
        default:
            break
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        prepareForRoute(using: segue, sender: sender)
    }

    // MARK: - User Interface

    private enum Tabs: Int {
        case downloadList, courseList
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
            performSegue(withRoute: .about)
        }

        func signOut(_: UIAlertAction) {
            viewModel.signOut()
            performSegue(withRoute: .signIn)
        }

        guard let currentUser = viewModel.currentUser else { return }
        let barButtonItem = sender as? UIBarButtonItem
        let title = "Signed in as %@".localized(currentUser.nameComponents.formatted(style: .long))

        let controller = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        controller.popoverPresentationController?.barButtonItem = barButtonItem
        controller.addAction(UIAlertAction(title: "About".localized, style: .default, handler: showAboutView))
        controller.addAction(UIAlertAction(title: "Sign Out".localized, style: .destructive, handler: signOut))
        controller.actions.last?.setValue(UI.Colors.studRed, forKey: "titleTextColor")
        controller.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
}
