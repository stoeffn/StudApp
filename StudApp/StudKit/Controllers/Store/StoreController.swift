//
//  StoreController.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class StoreController: UITableViewController, Routable {
    private var viewModel: StoreViewModel!

    // MARK: - Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = StoreViewModel()
        viewModel.loadProducts()
        viewModel.didLoadProducts = updateUserInterface

        titleLabel.text = App.name
        subtitleLabel.text = "Access all your Stud.IP courses and documents, including unlimited offline documents.".localized

        trialButton.setTitle("Start Free Trial".localized, for: .normal)

        orLabel.text = "——— or ———".localized

        unlockButton.setTitle("Unlock All Features".localized, for: .normal)

        restoreButton.setTitle("Restore Purchase".localized, for: .normal)

        disclaimerLabel.text = "DISCLAIMER".localized
    }

    // MARK: - User Interface

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var trialButton: FilledButton!

    @IBOutlet weak var orLabel: UILabel!

    @IBOutlet weak var unlockButton: FilledButton!

    @IBOutlet weak var restoreButton: UIButton!

    @IBOutlet weak var disclaimerLabel: UILabel!

    private func updateUserInterface() {
        trialButton.isEnabled = viewModel.subscriptionProduct != nil
        if let subscriptionProduct = viewModel.subscriptionProduct {
            let localizedSubscriptionPrice = NumberFormatter.localizedString(from: subscriptionProduct.price, number: .currency)
            let localizedButtonSubtitle = "%@ for six months after a 1-month trial".localized(localizedSubscriptionPrice)
            unlockButton.setTitle("Start Free Trial".localized + "\n" + localizedButtonSubtitle, for: .normal)
        }

        unlockButton.isEnabled = viewModel.unlockProduct != nil
        if let unlockProduct = viewModel.unlockProduct {
            let localizedUnlockPrice = NumberFormatter.localizedString(from: unlockProduct.price, number: .currency)
            unlockButton.setTitle("Unlock All Features for %@".localized(localizedUnlockPrice), for: .normal)
        }
    }

    // MARK: - User Interaction

    @IBAction
    func moreButtonTapped(_ sender: Any) {
        func showAboutView(_: UIAlertAction) {
            performSegue(withRoute: .about)
        }

        func signOut(_: UIAlertAction) {
            // TODO
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
        guard let product = viewModel.subscriptionProduct else { return }
        viewModel.buy(product: product)
    }

    @IBAction
    func unlockButtonTapped(_: Any) {
        guard let product = viewModel.unlockProduct else { return }
        viewModel.buy(product: product)
    }

    @IBAction
    func restoreButtonTapped(_: Any) {
        viewModel.restoreCompletedTransactions()
    }
}
