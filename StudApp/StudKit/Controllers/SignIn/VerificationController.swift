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
        viewModel.verifyStoreState { result in
            if let optionalRoute = result.value, let route = optionalRoute {
                self.performSegue(withRoute: route)
            }
        }

        navigationItem.hidesBackButton = true

        titleLabel.text = "Verifying Your Purchase…".localized
    }

    // MARK: - User Interface

    @IBOutlet weak var titleLabel: UILabel!
}
