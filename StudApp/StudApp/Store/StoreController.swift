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
        disclaimerView.sizeToFit()

        isLoading = true

        if viewModel.isPaymentDeferred {
            present(deferralAlert, animated: true, completion: nil)
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.addAsTransactionObserver()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        viewModel.removeAsTransactionObserver()
    }

    // MARK: - Table View Data Source

    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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

    private let disclaimerText = [
        "The former option is an auto-renewing subscription, whereas the latter is a one-time payment.".localized,
        "View our Privacy Policy and Terms of Use.".localized,
    ].joined(separator: " ")

    private let autoRenewingSubscriptionDisclaimerText = [
        "Payment will be charged to your iTunes account,".localized,
        "and your account will be charged for renewal 24 hours prior to the end of the current period.".localized,
        "Auto-renewal may be turned off at any time by going to your iTunes account settings after purchase.".localized,
    ].joined(separator: " ")

    private lazy var attributedDisclaimerText: NSAttributedString = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributedText = NSMutableAttributedString(string: disclaimerText, attributes: [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.preferredFont(forTextStyle: .footnote),
            .foregroundColor: UI.Colors.greyText,
        ])

        attributedText.addLink(for: "auto-renewing subscription".localized, to: App.Links.autorenewingSubscriptionDisclaimerUrl)
        attributedText.addLink(for: "Privacy Policy".localized, to: App.Links.privacyPolicy)
        attributedText.addLink(for: "Terms of Use".localized, to: App.Links.termsOfUse)

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

        func showHelpView(_: UIAlertAction) {
            guard let url = App.Links.help else { return }
            let controller = SFSafariViewController(url: url)
            controller.preferredControlTintColor = UI.Colors.tint
            present(controller, animated: true, completion: nil)
        }

        func signOut(_: UIAlertAction) {
            viewModel.signOut()
            performSegue(withRoute: .signIn)
        }

        let barButtonItem = sender as? UIBarButtonItem

        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.popoverPresentationController?.barButtonItem = barButtonItem
        controller.addAction(UIAlertAction(title: "About".localized, style: .default, handler: showAboutView))
        controller.addAction(UIAlertAction(title: "Help".localized, style: .default, handler: showHelpView))
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
        if url == App.Links.autorenewingSubscriptionDisclaimerUrl {
            performSegue(withRoute: .disclaimer(autoRenewingSubscriptionDisclaimerText))
            return false
        }

        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
        return false
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
            let alert = UIAlertController(alertWithTitle: "Something Went Wrong".localized,
                                          message: transaction.error?.localizedDescription)
            present(alert, animated: true, completion: nil)
        case .restored:
            performSegue(withRoute: .verification)
        case .deferred:
            present(deferralAlert, animated: true, completion: nil)
        }
    }

    // MARK: - Navigation

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if case .disclaimer? = sender as? Routes {
            let sourceRect = CGRect(x: disclaimerView.bounds.size.width / 2, y: 0, width: 0, height: 0)
            segue.destination.popoverPresentationController?.delegate = self
            segue.destination.popoverPresentationController?.sourceRect = sourceRect
            segue.destination.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        }
        prepareForRoute(using: segue, sender: sender)
    }
}

// MARK: - Popover Presentation

extension StoreController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
