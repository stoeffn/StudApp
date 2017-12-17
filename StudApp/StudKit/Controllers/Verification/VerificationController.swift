//
//  VerificationController.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class VerificationController: UIViewController, Routable {
    private var viewModel: VerificationViewModel!

    // MARK: - Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

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

    // MARK: - User Interaction

    @IBAction
    func actionButtonTapped(_: Any) {
        if viewModel.isAppUnlocked {
            dismiss(animated: true, completion: nil)
        } else {
            verifyStoreState()
        }
    }

    // MARK: - Helpers

    private func verifyStoreState() {
        activityIndicator.isHidden = false
        titleLabel.text = "Verifying Your Purchase…".localized
        subtitleLabel.isHidden = true
        actionButton.isHidden = true

        viewModel.verifyStoreState { result in
            self.activityIndicator.isHidden = true

            guard result.isSuccess, let isAppUnlocked = result.value else {
                self.titleLabel.text = "Something Went Wrong Veryifying Your Purchase".localized
                self.subtitleLabel.text = result.error?.localizedDescription
                    ?? "There seems to be a problem with the internet connection.".localized
                self.actionButton.setTitle("Retry".localized, for: .normal)
                self.actionButton.isHidden = false
                return
            }

            if isAppUnlocked {
                self.titleLabel.text = "Thank You for Supporting StudApp!".localized
                self.actionButton.setTitle("Dismiss".localized, for: .normal)
                self.actionButton.isHidden = false

                self.confettiView.alpha = 0
                self.confettiView.intensity = 0
                let animator = UIViewPropertyAnimator(duration: 3, curve: .easeInOut) {
                    self.confettiView.alpha = 1
                    self.confettiView.intensity = 1
                }
                animator.startAnimation()
            } else {
                // TODO: Redirect to main app if inside file provider
                self.performSegue(withRoute: .store)
            }
        }
    }
}
