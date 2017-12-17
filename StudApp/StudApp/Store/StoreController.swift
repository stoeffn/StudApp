//
//  StoreController.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import SafariServices
import StoreKit
import StudKit

public final class StoreController: UITableViewController, UITextViewDelegate, Routable {
    private var viewModel: StoreViewModel!

    // MARK: - Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = StoreViewModel()
        viewModel.loadProducts()
        viewModel.didLoadProducts = didLoadProducts
        viewModel.transactionChanged = transactionChanged

        navigationItem.hidesBackButton = true

        titleLabel.text = App.name
        subtitleLabel.text = "Access all your Stud.IP courses and documents, including unlimited offline documents.".localized

        trialButton.setTitle("Start Free Trial".localized, for: .normal)

        orLabel.text = "——— or ———".localized

        unlockButton.setTitle("Unlock All Features".localized, for: .normal)

        restoreButton.setTitle("Restore Purchase".localized, for: .normal)

        disclaimerView.attributedText = attributedDisclaimerText

        isLoading = true

        if viewModel.isPaymentDeferred {
            present(deferralAlert, animated: true, completion: nil)
        }
    }

    // MARK: - User Interface

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var trialButton: FilledButton!

    @IBOutlet weak var orLabel: UILabel!

    @IBOutlet weak var unlockButton: FilledButton!

    @IBOutlet weak var restoreButton: UIButton!

    @IBOutlet weak var disclaimerView: UITextView!

    private lazy var deferralAlert = UIAlertController(title: "Your Purchase is Deferred".localized,
                                                       message: "A family member might have to approve this puchase.".localized,
                                                       preferredStyle: .alert)

    private var attributedDisclaimerText: NSAttributedString = {
        let text = [
            "The former option is an auto-renewing subscription, whereas the latter is a one-time payment.".localized,
            "View our Privacy Policy and Terms of Use.".localized,
        ].joined(separator: " ")

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributedText = NSMutableAttributedString(string: text, attributes: [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UI.Colors.greyText,
        ])

        attributedText.addLink(for: "auto-renewing subscription".localized, to: App.url)
        attributedText.addLink(for: "Privacy Policy".localized, to: App.url)
        attributedText.addLink(for: "Terms of Use".localized, to: App.url)

        return attributedText
    }()

    private func updateTrialButton(withProduct product: SKProduct?) {
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

    private var isLoading: Bool = false {
        didSet {
            navigationItem.setActivityIndicatorHidden(!isLoading)
            trialButton.isEnabled = !isLoading && viewModel.subscriptionProduct != nil
            unlockButton.isEnabled = !isLoading && viewModel.unlockProduct != nil
            restoreButton.isEnabled = !isLoading
        }
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

    public func textView(_: UITextView, shouldInteractWith url: URL, in _: NSRange,
                         interaction _: UITextItemInteraction) -> Bool {
        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
        return true
    }

    // MARK: - Store Events

    private func didLoadProducts() {
        UIView.animate(withDuration: 0.3) {
            self.isLoading = false
            self.updateTrialButton(withProduct: self.viewModel.subscriptionProduct)
            self.updateUnlockButton(withProduct: self.viewModel.unlockProduct)
        }
    }

    private func transactionChanged(_ transaction: SKPaymentTransaction) {
        deferralAlert.dismiss(animated: true, completion: nil)

        switch transaction.transactionState {
        case .purchasing:
            isLoading = true
        case .purchased:
            performSegue(withRoute: .verification)
        case .failed:
            isLoading = false
            let alert = UIAlertController(title: "Something Went Wrong".localized,
                                          message: transaction.error?.localizedDescription)
            present(alert, animated: true, completion: nil)
        case .restored:
            performSegue(withRoute: .verification)
        case .deferred:
            present(deferralAlert, animated: true, completion: nil)
        }
    }
}
