//
//  SignInController.swift
//  StudApp
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import SafariServices

final class SignInController: UIViewController, Routable {
    private var contextService: ContextService!
    private var viewModel: SignInViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        contextService = ServiceContainer.default[ContextService.self]

        viewModel.authorizationUrl { result in
            guard let url = result.value else {
                // TODO: Handle error
                return
            }
            self.authorize(at: url)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var organization = viewModel.organization
        iconView.image = organization.iconThumbnail
        titleLabel.text = organization.title

        viewModel.organizationIcon { icon in
            UIView.transition(with: self.view, duration: 0.1, options: .transitionCrossDissolve, animations: {
                self.iconView.image = icon.value
            }, completion: nil)
        }
    }

    func prepareDependencies(for route: Routes) {
        guard case let .signIntoOrganization(organization) = route else { fatalError() }

        viewModel = SignInViewModel(organization: organization)
    }

    // MARK: - User Interface

    @IBOutlet weak var iconView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var activityIndicator: StudIpActivityIndicatorView!

    /// Weakly typed because `@available` cannot be applied to properties.
    private var authenticationSession: NSObject?

    var isLoading = false {
        didSet {
            guard isLoading != oldValue else { return }
            navigationItem.setActivityIndicatorHidden(!isLoading)
        }
    }

    func authorize(at url: URL) {
        guard #available(iOSApplicationExtension 11.0, *) else {
            // TODO:
            fatalError()
        }

        let session = SFAuthenticationSession(url: url, callbackURLScheme: App.scheme) { url, _ in
            self.authenticationSession = nil

            guard let url = url else {
                self.dismiss(animated: true, completion: nil)
                return
            }

            self.viewModel.handleAuthorizationCallback(url: url, handler: { result in
                guard result.isSuccess else {
                    // TODO: Handle error
                    return
                }
                self.dismissSignIn()
            })
        }
        session.start()

        authenticationSession = session
    }

    func dismissSignIn() {
        switch contextService.currentTarget {
        case .app:
            presentingViewController?.dismiss(animated: true, completion: nil)
        case .fileProviderUI:
            contextService.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        default:
            break
        }
    }

    // MARK: - User Interaction

    @IBAction
    func moreButtonTapped(_ sender: Any) {
        func showAboutView(_: UIAlertAction) {
            performSegue(withRoute: .about)
        }

        let barButtonItem = sender as? UIBarButtonItem

        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.popoverPresentationController?.barButtonItem = barButtonItem
        controller.addAction(UIAlertAction(title: "About".localized, style: .default, handler: showAboutView))
        controller.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
}
