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

import SafariServices
import StudKit
import StudKitUI

final class AppController: UITabBarController {
    private var htmlContentService: HtmlContentService!
    private var viewModel: AppViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        htmlContentService = ServiceContainer.default[HtmlContentService.self]

        NotificationCenter.default.addObserver(self, selector: #selector(currentUserDidChange(notification:)),
                                               name: .currentUserDidChange, object: nil)

        view.backgroundColor = .white

        viewModel = AppViewModel()
        viewModel.update()
    }

    override func viewWillAppear(_ animated: Bool) {
        prepareChildContents(for: User.current)

        super.viewWillAppear(animated)

        tabBar.items?[Tabs.courses.rawValue].title = "Courses".localized
        tabBar.items?[Tabs.events.rawValue].title = "Events".localized
        tabBar.items?[Tabs.downloads.rawValue].title = "Downloads".localized
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSignInIfNeeded()
    }

    // MARK: - Supporting User Activities

    override func restoreUserActivityState(_ activity: NSUserActivity) {
        switch activity.objectIdentifier?.entity {
        case .file?:
            selectedIndex = Tabs.downloads.rawValue
            downloadsController?.restoreUserActivityState(activity)
        case .course?:
            selectedIndex = Tabs.courses.rawValue
            coursesController?.restoreUserActivityState(activity)
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
            selectedIndex = Tabs.courses.rawValue
        case .presentDownloads:
            selectedIndex = Tabs.downloads.rawValue
        }
        return true
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        prepareForRoute(using: segue, sender: sender)
    }

    @IBAction
    func unwindToApp(with _: UIStoryboardSegue) {}

    @IBAction
    func unwindToAppAndSignOut(with segue: UIStoryboardSegue) {
        (segue as? UIStoryboardSegueWithCompletion)?.completion = {
            self.viewModel.signOut()
        }
    }

    func prepareChildContents(for user: User?) {
        coursesController?.prepareContent(for: .courseList(for: user))
        eventsController?.prepareContent(for: .eventList(for: user))
        downloadsController?.prepareContent(for: .downloadList(for: user))
    }

    func presentSignInIfNeeded() {
        if !viewModel.isSignedIn && presentedViewController == nil {
            performSegue(withRoute: .signIn)
        }
    }

    // MARK: - User Interface

    private enum Tabs: Int {
        case courses, events, downloads
    }

    var coursesController: CourseListController? {
        return viewControllers?
            .compactMap { $0 as? UISplitViewController }
            .compactMap { $0.viewControllers.first }
            .compactMap { $0 as? UINavigationController }
            .compactMap { $0.viewControllers.first }
            .compactMap { $0 as? CourseListController }
            .first
    }

    var eventsController: EventListController? {
        return viewControllers?
            .compactMap { $0 as? UINavigationController }
            .compactMap { $0.viewControllers.first }
            .compactMap { $0 as? EventListController }
            .first
    }

    var downloadsController: DownloadListController? {
        return viewControllers?
            .compactMap { $0 as? UINavigationController }
            .compactMap { $0.viewControllers.first }
            .compactMap { $0 as? DownloadListController }
            .first
    }

    func controllerForMore(at barButtonItem: UIBarButtonItem? = nil) -> UIViewController {
        guard let currentUser = User.current else { fatalError() }

        let actions = [
            UIAlertAction(title: "About".localized, style: .default) { _ in
                self.performSegue(withRoute: .about)
            },
            UIAlertAction(title: "Help".localized, style: .default) { _ in
                self.present(self.htmlContentService.safariViewController(for: App.Urls.help), animated: true, completion: nil)
            },
            UIAlertAction(title: "Settings".localized, style: .default) { _ in
                self.performSegue(withRoute: .settings)
            },
            UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil),
        ]

        let currentUserFullName = currentUser.nameComponents.formatted(style: .long)
        let title = "Signed in as %@ at %@".localized(currentUserFullName, currentUser.organization.title)
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        controller.popoverPresentationController?.barButtonItem = barButtonItem
        actions.forEach(controller.addAction)
        return controller
    }

    // MARK: - User Interaction

    @IBAction
    func userButtonTapped(_ sender: Any) {
        present(controllerForMore(at: sender as? UIBarButtonItem), animated: true, completion: nil)
    }

    // MARK: - Notifications

    @objc
    private func currentUserDidChange(notification _: Notification) {
        prepareChildContents(for: User.current)
        presentSignInIfNeeded()
    }

    // MARK: - Exposing Methods

    func updateViewModel() {
        viewModel.update()
    }
}
