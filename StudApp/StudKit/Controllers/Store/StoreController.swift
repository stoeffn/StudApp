//
//  StoreController.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StoreKit

public final class StoreController: UITableViewController, Routable {
    private var viewModel: StoreViewModel!

    // MARK: - Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = StoreViewModel()
        viewModel.loadProducts()
        viewModel.didLoadProducts = {
            self.navigationItem.setActivityIndicatorHidden(true)
            UIView.animate(withDuration: 0.3, animations: self.updateUserInterface)
        }

        navigationItem.hidesBackButton = true
        navigationItem.setActivityIndicatorHidden(false)

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
        updateTrialButton(withProduct: viewModel.subscriptionProduct)
        updateUnlockButton(withProduct: viewModel.unlockProduct)
    }

    private func updateTrialButton(withProduct product: SKProduct?) {
        trialButton.isEnabled = product != nil

        guard let product = product else { return }

        let localizedSubscriptionPrice = NumberFormatter.localizedString(from: product.price, number: .currency)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let localizedTitle = "Start Free Trial".localized
        let title = NSAttributedString(string: localizedTitle, attributes: [
            .paragraphStyle: paragraphStyle,
        ])

        let localizedSubtitle = "%@ for six months after a 1-month trial".localized(localizedSubscriptionPrice)
        let subtitle = NSAttributedString(string: localizedSubtitle, attributes: [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.preferredFont(forTextStyle: .footnote),
            .foregroundColor: UIColor.white.withAlphaComponent(0.6),
        ])

        let attributedButtonTitle = NSMutableAttributedString()
        attributedButtonTitle.append(title)
        attributedButtonTitle.append(NSAttributedString(string: "\n"))
        attributedButtonTitle.append(subtitle)

        trialButton.setAttributedTitle(attributedButtonTitle, for: .normal)
    }

    private func updateUnlockButton(withProduct product: SKProduct?) {
        unlockButton.isEnabled = product != nil

        guard let product = product else { return }

        let localizedUnlockPrice = NumberFormatter.localizedString(from: product.price, number: .currency)
        unlockButton.setTitle("Unlock All Features for %@".localized(localizedUnlockPrice), for: .normal)
    }

    // MARK: - User Interaction

    @IBAction
    func moreButtonTapped(_ sender: Any) {
        func showAboutView(_: UIAlertAction) {
            performSegue(withRoute: .about)
        }

        func signOut(_: UIAlertAction) {
            viewModel.signOut()
            performSegue(withRoute: .signIn)
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
