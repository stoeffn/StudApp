//
//  VerificationController.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class VerificationController: UIViewController, Routable {
    private var contextService: ContextService!
    private var viewModel: VerificationViewModel!

    // MARK: - Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        contextService = ServiceContainer.default[ContextService.self]

        viewModel = VerificationViewModel()

        navigationItem.hidesBackButton = true

        verifyStoreState()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        (navigationController as? BorderlessNavigationController)?.isNavigationBarBackgroundHidden = true
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        (navigationController as? BorderlessNavigationController)?.isNavigationBarBackgroundHidden = false
    }

    // MARK: - User Interface

    @IBOutlet weak var activityIndicator: StudIpActivityIndicatorView!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var actionButton: UIButton!

    @IBOutlet weak var confettiView: ConfettiView!

    private func show(_ error: Error?) {
        activityIndicator.isHidden = true
        titleLabel.text = "Something Went Wrong Veryifying Your Purchase".localized
        subtitleLabel.text = error?.localizedDescription
            ?? "There seems to be a problem with the internet connection.".localized
        actionButton.setTitle("Retry".localized, for: .normal)
        actionButton.isHidden = false
    }

    private func dismissVerification() {
        if viewModel.isAppUnlocked {
            switch contextService.currentTarget {
            case .app:
                dismiss(animated: true, completion: nil)
            case .fileProviderUI:
                contextService.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            default:
                fatalError()
            }
        } else {
            verifyStoreState()
        }
    }

    private func showStore() {
        switch contextService.currentTarget {
        case .app:
            performSegue(withRoute: .store)
        case .fileProviderUI:
            activityIndicator.isHidden = true
            titleLabel.text = "Please open StudApp".localized

            guard let url = App.Links.appStore else { return }
            contextService.openUrl?(url) { _ in
                guard #available(iOSApplicationExtension 11.0, *) else { return }
                let error = NSFileProviderError(.notAuthenticated, userInfo: [
                    NSFileProviderError.reasonKey: NSFileProviderError.Reasons.noVerifiedPurchase.rawValue,
                ])
                self.contextService.extensionContext?.cancelRequest(withError: error)
            }
        default:
            fatalError()
        }
    }

    private func showThankYouMessage() {
        activityIndicator.isHidden = true
        titleLabel.text = "Thank You for Supporting StudApp!".localized
        actionButton.setTitle("Dismiss".localized, for: .normal)
        actionButton.isHidden = false

        confettiView.alpha = 0
        confettiView.intensity = 0
        let animator = UIViewPropertyAnimator(duration: 3, curve: .easeInOut) {
            self.confettiView.alpha = 1
            self.confettiView.intensity = 1
        }
        animator.startAnimation()
    }

    // MARK: - User Interaction

    @IBAction
    func actionButtonTapped(_: Any) {
        guard viewModel.isAppUnlocked else { return verifyStoreState() }
        dismissVerification()
    }

    // MARK: - Helpers

    private func verifyStoreState() {
        activityIndicator.isHidden = false
        titleLabel.text = "Verifying Your Purchase…".localized
        subtitleLabel.isHidden = true
        actionButton.isHidden = true

        viewModel.verifyStoreState { result in
            guard result.isSuccess, let isAppUnlocked = result.value else { return self.show(result.error) }
            guard isAppUnlocked else { return self.showStore() }
            self.showThankYouMessage()
        }
    }
}
