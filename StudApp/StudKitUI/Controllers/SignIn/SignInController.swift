//
//  SignInController.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import SafariServices
import StudKit

final class SignInController: UIViewController, Routable, SFSafariViewControllerDelegate {
    private var contextService: ContextService!
    private var viewModel: SignInViewModel!
    private var observations = [NSKeyValueObservation]()
    private var completion: ((SignInResult) -> Void)!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        contextService = ServiceContainer.default[ContextService.self]

        NotificationCenter.default.addObserver(self, selector: #selector(safariViewControllerDidLoadAppUrl(notification:)),
                                               name: .safariViewControllerDidLoadAppUrl, object: nil)

        // iconView.image = organization.iconThumbnail
        titleLabel.text = viewModel.organization.title
        areOrganizationViewsHidden = true
        isActivityIndicatorHidden = true

        observations = [
            viewModel.observe(\.state) { [weak self] (_, _) in
                guard let `self` = self else { return }
                self.updateUserInterface(for: self.viewModel.state)
            },
            viewModel.observe(\.error) { [weak self] (_, _) in
                guard let `self` = self, let error = self.viewModel.error else { return }
                self.present(self.controller(for: error), animated: true, completion: nil)
            },
            viewModel.observe(\.organizationIcon) { [weak self] (_, _) in
                guard let `self` = self else { return }
                UIView.transition(with: self.view, duration: 0.1, options: .transitionCrossDissolve, animations: {
                    self.iconView.image = self.viewModel.organizationIcon ?? self.iconView.image
                }, completion: nil)
            },
        ]

        viewModel.updateOrganizationIcon()
        viewModel.startAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        animateWithSpring {
            self.areOrganizationViewsHidden = false
            self.isActivityIndicatorHidden = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        animateWithSpring {
            self.areOrganizationViewsHidden = true
            self.isActivityIndicatorHidden = true
        }
    }

    func prepareDependencies(for route: Routes) {
        guard case let .signIntoOrganization(organization, completion) = route else { fatalError() }
        self.completion = completion

        viewModel = SignInViewModel(organization: organization)
    }

    // MARK: - User Interface

    @IBOutlet var iconView: UIImageView!

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var activityIndicator: StudIpActivityIndicator!

    /// Weakly typed because `@available` cannot be applied to properties.
    private var authenticationSession: NSObject?

    var areOrganizationViewsHidden: Bool = true {
        didSet {
            iconView.transform = areOrganizationViewsHidden ? CGAffineTransform(scaleX: 0.1, y: 0.1) : .identity
            iconView.alpha = areOrganizationViewsHidden ? 0 : 1
            titleLabel.alpha = areOrganizationViewsHidden ? 0 : 1
        }
    }
    var isActivityIndicatorHidden: Bool = false {
        didSet {
            activityIndicator.transform = isActivityIndicatorHidden ? CGAffineTransform(scaleX: 0.1, y: 0.1) : .identity
            activityIndicator.alpha = isActivityIndicatorHidden ? 0 : 1
        }
    }

    private func animateWithSpring(animations: @escaping () -> Void) {
        UIView.animate(withDuration: UI.defaultAnimationDuration, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0, options: .curveEaseOut, animations: animations, completion: nil)
    }

    func controller(for error: Error) -> UIViewController {
        let message = error.localizedDescription
        let controller = UIAlertController(title: "Error Signing In".localized, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Retry".localized, style: .default) { _ in self.viewModel.retry() })
        controller.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel) { _ in self.completion(.none) })
        return controller
    }

    func updateUserInterface(for state: SignInViewModel.State) {
        switch state {
        case .updatingRequestToken:
            animateWithSpring {
                self.isActivityIndicatorHidden = false
            }
        case .authorizing:
            guard let url = viewModel.authorizationUrl else { return }
            authorize(at: url)
        case .updatingAccessToken:
            animateWithSpring {
                self.isActivityIndicatorHidden = false
            }
        case .signedIn:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            completion(.signedIn)
        }
    }

    // MARK: - Authorizing the Application

    private func authorize(at url: URL) {
        guard #available(iOSApplicationExtension 11.0, *), contextService.currentTarget == .app else {
            let controller = SFSafariViewController(url: url)
            controller.delegate = self
            controller.preferredControlTintColor = UI.Colors.studBlue
            return present(controller, animated: true, completion: nil)
        }

        let session = SFAuthenticationSession(url: url, callbackURLScheme: App.scheme) { url, _ in
            self.authenticationSession = nil

            guard let url = url else { return self.completion(.none) }
            self.viewModel.finishAuthorization(withCallbackUrl: url)
        }
        session.start()

        authenticationSession = session
    }

    // MARK: - Notifications

    @objc
    private func safariViewControllerDidLoadAppUrl(notification: Notification) {
        guard let url = notification.userInfo?[Notification.Name.safariViewControllerDidLoadAppUrlKey] as? URL else { return }
        presentedViewController?.dismiss(animated: true) {
            self.viewModel.finishAuthorization(withCallbackUrl: url)
        }
    }

    func safariViewControllerDidFinish(_: SFSafariViewController) {
        completion(.none)
    }
}
