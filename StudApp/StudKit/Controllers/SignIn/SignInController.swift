//
//  SignInController.swift
//  StudApp
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import SafariServices

final class SignInController: UIViewController, Routable, SFSafariViewControllerDelegate {
    private var contextService: ContextService!
    private var viewModel: SignInViewModel!
    private var completionHandler: ((SignInResult) -> Void)?

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        contextService = ServiceContainer.default[ContextService.self]

        NotificationCenter.default.addObserver(self, selector: #selector(safariViewControllerDidLoadAppUrl(notification:)),
                                               name: .safariViewControllerDidLoadAppUrl, object: nil)

        var organization = viewModel.organization
        iconView.image = organization.iconThumbnail
        titleLabel.text = organization.title

        viewModel.organizationIcon { icon in
            UIView.transition(with: self.view, duration: 0.1, options: .transitionCrossDissolve, animations: {
                self.iconView.image = icon.value ?? self.iconView.image
            }, completion: nil)
        }

        startAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        areOrganizationViewsHidden = false
        isLoading = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        areOrganizationViewsHidden = true
        isLoading = false
    }

    func prepareDependencies(for route: Routes) {
        guard case let .signIntoOrganization(organization, handler) = route else { fatalError() }
        viewModel = SignInViewModel(organization: organization)
        completionHandler = handler
    }

    // MARK: - User Interface

    @IBOutlet weak var iconView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var activityIndicator: StudIpActivityIndicatorView!

    /// Weakly typed because `@available` cannot be applied to properties.
    private var authenticationSession: NSObject?

    var areOrganizationViewsHidden: Bool = true {
        didSet {
            guard areOrganizationViewsHidden != oldValue else { return }

            iconView.transform = areOrganizationViewsHidden ? .identity : CGAffineTransform(scaleX: 0.1, y: 0.1)
            iconView.alpha = areOrganizationViewsHidden ? 1 : 0
            titleLabel.alpha = areOrganizationViewsHidden ? 1 : 0

            UIView.animate(withDuration: UI.defaultAnimationDuration, delay: 0, usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.iconView.transform = self.areOrganizationViewsHidden ? CGAffineTransform(scaleX: 0.1, y: 0.1) : .identity
                self.iconView.alpha = self.areOrganizationViewsHidden ? 0 : 1
                self.titleLabel.alpha = self.areOrganizationViewsHidden ? 0 : 1
            }, completion: nil)
        }
    }

    var isLoading: Bool = false {
        didSet {
            guard isLoading != oldValue else { return }

            activityIndicator.transform = isLoading ? CGAffineTransform(scaleX: 0.1, y: 0.1) : .identity
            activityIndicator.alpha = isLoading ? 0 : 1

            UIView.animate(withDuration: UI.defaultAnimationDuration, delay: 0, usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.activityIndicator.transform = self.isLoading ? .identity : CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.activityIndicator.alpha = self.isLoading ? 1 : 0
            }, completion: nil)
        }
    }

    // MARK: - Authorizing the Application

    private func startAuthorization() {
        isLoading = true
        viewModel.authorizationUrl { result in
            guard let url = result.value else {
                self.isLoading = false

                let message = result.error?.localizedDescription
                let alert = UIAlertController(title: "Error Signing In".localized, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry".localized, style: .default, handler: { _ in
                    self.startAuthorization()
                }))
                alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { _ in
                    self.completionHandler?(.none)
                }))
                return self.present(alert, animated: true, completion: nil)
            }

            DispatchQueue.main.async {
                self.authorize(at: url)
            }
        }
    }

    private func authorize(at url: URL) {
        isLoading = true

        guard #available(iOSApplicationExtension 11.0, *), contextService.currentTarget == .app else {
            let controller = SFSafariViewController(url: url)
            controller.delegate = self
            controller.preferredControlTintColor = UI.Colors.studBlue
            return present(controller, animated: true, completion: nil)
        }

        let session = SFAuthenticationSession(url: url, callbackURLScheme: App.scheme) { url, _ in
            self.authenticationSession = nil

            guard let url = url else {
                self.completionHandler?(.none)
                return
            }

            self.finishAuthorization(withCallbackUrl: url)
        }
        session.start()

        authenticationSession = session
    }

    private func finishAuthorization(withCallbackUrl url: URL) {
        isLoading = true
        viewModel.handleAuthorizationCallback(url: url) { result in
            self.isLoading = false

            guard result.isSuccess else {
                self.isLoading = false

                let message = result.error?.localizedDescription
                let alert = UIAlertController(title: "Error Signing In".localized, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry".localized, style: .default, handler: { _ in
                    self.finishAuthorization(withCallbackUrl: url)
                }))
                alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { _ in
                    self.completionHandler?(.none)
                }))
                return self.present(alert, animated: true, completion: nil)
            }

            self.completionHandler?(.signedIn)
        }
    }

    // MARK: - Notifications

    @objc
    private func safariViewControllerDidLoadAppUrl(notification: Notification) {
        guard let url = notification.userInfo?[Notification.Name.safariViewControllerDidLoadAppUrlKey] as? URL else { return }
        presentedViewController?.dismiss(animated: true) {
            self.finishAuthorization(withCallbackUrl: url)
        }
    }

    func safariViewControllerDidFinish(_: SFSafariViewController) {
        completionHandler?(.none)
    }
}
