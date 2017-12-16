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

        retryButton.setTitle("Retry".localized, for: .normal)

        verifyStoreState()
    }

    // MARK: - User Interface

    @IBOutlet weak var activityIndicator: StudIpActivityIndicatorView!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var retryButton: UIButton!

    // MARK: - User Interaction

    @IBAction
    func retryButtonTapped(_: Any) {
        verifyStoreState()
    }

    // MARK: - Helpers

    private func verifyStoreState() {
        activityIndicator.isHidden = false
        titleLabel.text = "Verifying Your Purchase…".localized
        subtitleLabel.isHidden = true
        retryButton.isHidden = true

        viewModel.verifyStoreState { result in
            guard result.isSuccess, let optionalRoute = result.value else {
                self.activityIndicator.isHidden = true
                self.titleLabel.text = "Something Went Wrong Veryifying Your Purchase".localized
                self.subtitleLabel.text = result.error?.localizedDescription
                    ?? "There seems to be a problem with the internet connection.".localized
                self.retryButton.isHidden = false
                return
            }
            if let route = optionalRoute {
                self.performSegue(withRoute: route)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
