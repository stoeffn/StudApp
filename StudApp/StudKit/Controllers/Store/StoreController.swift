//
//  StoreController.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit

public final class StoreController: UITableViewController {
    // MARK: - Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - User Interface

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var trialButton: FilledButton!

    @IBOutlet weak var orLabel: UILabel!

    @IBOutlet weak var unlockButton: FilledButton!

    @IBOutlet weak var restoreButton: UIButton!

    @IBOutlet weak var disclaimerLabel: UILabel!

    // MARK: - User Interaction

    @IBAction
    func moreButtonTapped(_ sender: Any) {
        func showAboutView(_: UIAlertAction) {
            performSegue(withRoute: .about)
        }

        func signOut(_: UIAlertAction) {
            // TODO:
            print("TODO")
        }

        let barButtonItem = sender as? UIBarButtonItem

        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.popoverPresentationController?.barButtonItem = barButtonItem
        controller.addAction(UIAlertAction(title: "About".localized, style: .default, handler: showAboutView))
        controller.addAction(UIAlertAction(title: "Sign Out".localized, style: .destructive, handler: signOut))
        controller.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }

    @IBAction
    func trialButtonTapped(_: Any) {
    }

    @IBAction
    func unlockButtonTapped(_: Any) {
    }

    @IBAction
    func restoreButtonTapped(_: Any) {
    }
}
