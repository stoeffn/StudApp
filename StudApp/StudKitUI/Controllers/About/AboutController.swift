//
//  AboutController.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 28.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import MessageUI
import SafariServices
import StoreKit
import StudKit

final class AboutController: UITableViewController, Routable {
    private let contextService = ServiceContainer.default[ContextService.self]
    private var viewModel: AboutViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "About".localized

        tableView.register(ThanksNoteCell.self, forCellReuseIdentifier: ThanksNoteCell.typeIdentifier)

        titleLabel.text = "\(App.name) \(App.versionName)"
        subtitleLabel.text = "by %@".localized(App.authorName)

        websiteCell.textLabel?.text = "Website".localized
        privacyCell.textLabel?.text = "Privacy Policy".localized

        sendFeedbackCell.textLabel?.text = "Send Feedback".localized
        rateAppCell.textLabel?.text = "Rate StudApp".localized

        tipCell.textLabel?.text = "Leave a Tip".localized
    }

    func prepareContent(for route: Routes) {
        guard case .about = route else { fatalError() }

        viewModel = AboutViewModel()
        viewModel.leaveTipCompletion = didLeaveTip
    }

    // MARK: - User Interface

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var subtitleLabel: UILabel!

    @IBOutlet var websiteCell: UITableViewCell!

    @IBOutlet var privacyCell: UITableViewCell!

    @IBOutlet var sendFeedbackCell: UITableViewCell!

    @IBOutlet var rateAppCell: UITableViewCell!

    @IBOutlet var tipCell: UITableViewCell!

    // MARK: - User Interaction

    @IBAction
    func doneButtonTapped(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction
    func actionButtonTapped(_: Any) {
        let controller = UIActivityViewController(activityItems: [App.Urls.appStore], applicationActivities: nil)
        controller.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(controller, animated: true, completion: nil)
    }

    // MARK: - Table View Data Source

    private enum Sections: Int {
        case app, links, feedback, tip, thanks
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .thanks?:
            return viewModel.numberOfRows
        case .app?, .links?, .tip?, .feedback?, nil:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .thanks?:
            let cell = tableView.dequeueReusableCell(withIdentifier: ThanksNoteCell.typeIdentifier, for: indexPath)
            (cell as? ThanksNoteCell)?.thanksNote = viewModel[rowAt: indexPath.row]
            return cell
        case .app?, .links?, .tip?, .feedback?, nil:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .thanks?:
            return "Thanks to".localized
        case .app?, .links?, .tip?, .feedback?, nil:
            return nil
        }
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .feedback?:
            return "We would appreciate your review on the App Store!".localized
        case .tip?:
            return [
                "If you really like this app you can leave a tip to support further development.".localized,
                "Thank you so much for even considering!".localized,
            ].joined(separator: " ")
        case .thanks?:
            return "Without you, this app could not exist. Thank you ❤️".localized
        case .app?, .links?, nil:
            return nil
        }
    }

    // MARK: Table View Delegate

    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        // Needs to be overridden in order to avoid index-out-of-range-exceptions caused by static cells.
        switch Sections(rawValue: indexPath.section) {
        case .thanks?:
            return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: indexPath.section))
        default:
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        // Needs to be overriden in order to activate dynamic row sizing. This value is not set in interface builder because it
        // would reset the rows' sizes to the default size in preview.
        return UITableViewAutomaticDimension
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        switch Sections(rawValue: indexPath.section) {
        case .links? where cell === websiteCell:
            openInSafari(App.Urls.website)
        case .links? where cell === privacyCell:
            openInSafari(App.Urls.privacyPolicy)
        case .feedback? where cell === sendFeedbackCell:
            openFeedbackMailComposer()
            tableView.deselectRow(at: indexPath, animated: true)
        case .feedback? where cell === rateAppCell:
            openAppStoreReviewPage()
            tableView.deselectRow(at: indexPath, animated: true)
        case .tip? where cell === tipCell:
            presentTips()
            tableView.deselectRow(at: indexPath, animated: true)
        case .thanks?:
            openInSafari(viewModel[rowAt: indexPath.row].url)
        default:
            break
        }
    }

    override func tableView(_: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        switch Sections(rawValue: indexPath.section) {
        case .links?, .feedback?:
            return true
        case .thanks?:
            return viewModel[rowAt: indexPath.row].url != nil
        default:
            return false
        }
    }

    override func tableView(_: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath,
                            withSender _: Any?) -> Bool {
        switch Sections(rawValue: indexPath.section) {
        case .links?, .feedback?:
            return action == #selector(copy(_:))
        case .thanks?:
            guard viewModel[rowAt: indexPath.row].url != nil else { return false }
            return action == #selector(copy(_:))
        default:
            return false
        }
    }

    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath,
                            withSender _: Any?) {
        let cell = tableView.cellForRow(at: indexPath)

        switch Sections(rawValue: indexPath.section) {
        case .links? where cell === websiteCell:
            UIPasteboard.general.url = App.Urls.website
        case .links? where cell === privacyCell:
            UIPasteboard.general.url = App.Urls.privacyPolicy
        case .feedback? where cell === sendFeedbackCell:
            UIPasteboard.general.string = App.feedbackMailAddress
        case .feedback? where cell === rateAppCell:
            UIPasteboard.general.url = App.Urls.review
        case .thanks?:
            UIPasteboard.general.url = viewModel[rowAt: indexPath.row].url
        default:
            fatalError()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        prepareForRoute(using: segue, sender: sender)
    }

    // MARK: - Opening Web Pages and Apps

    private func openInSafari(_ url: URL?) {
        guard let url = url else { return }

        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = UI.Colors.studBlue
        present(controller, animated: true, completion: nil)
    }

    private func openFeedbackMailComposer() {
        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        mailController.setToRecipients([App.feedbackMailAddress])
        mailController.setSubject("Feedback for %@".localized(App.name))

        if MFMailComposeViewController.canSendMail() {
            present(mailController, animated: true, completion: nil)
        }
    }

    private func openAppStoreReviewPage() {
        contextService.openUrl?(App.Urls.review) { success in
            guard !success else { return }

            let title = "Could not launch App Store".localized
            let message = "It would be kind if you rated StudApp anyway by opening the App Store manually.".localized
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay".localized, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Leaving Tips

    private func alertAction(for product: SKProduct) -> UIAlertAction {
        let localizedPrice = NumberFormatter.localizedString(from: product.price, number: .currency)
        let title = "\(product.localizedTitle) (\(localizedPrice))"

        return UIAlertAction(title: title, style: .default) { _ in
            self.navigationItem.setActivityIndicatorHidden(false)
            self.viewModel.leaveTip(with: product)
        }
    }

    private func presentTips() {
        navigationItem.setActivityIndicatorHidden(false)

        viewModel.tipProducts { products in
            self.navigationItem.setActivityIndicatorHidden(true)

            let message = [
                "If you really like this app you can leave a tip to support further development.".localized,
                "Thank you so much for even considering!".localized,
            ].joined(separator: " ")
            let controller = UIAlertController(title: "Leave a Tip".localized, message: message, preferredStyle: .alert)
            products
                .sorted { $0.price.decimalValue < $1.price.decimalValue }
                .map(self.alertAction)
                .forEach(controller.addAction)
            controller.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
            self.present(controller, animated: true, completion: nil)
        }
    }

    private func didLeaveTip(with transaction: SKPaymentTransaction) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        switch transaction.transactionState {
        case .purchased, .restored, .deferred:
            navigationItem.setActivityIndicatorHidden(true)

            let message = "I am glad there are people like you who value the work put into apps.".localized
            let controller = UIAlertController(title: "Thank You So Much!".localized, message: message, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Okay".localized, style: .cancel) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.presentedViewController?.dismiss(animated: true, completion: nil)
                }
            })
            performSegue(withRoute: .confetti(alert: controller))
        case .failed:
            navigationItem.setActivityIndicatorHidden(true)

            let message = "It would be kind if you retried in a little bit.".localized
            let controller = UIAlertController(title: "Something Went Wrong".localized, message: message, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Okay".localized, style: .cancel, handler: nil))
            present(controller, animated: true, completion: nil)
        default:
            break
        }
    }
}

// MARK: - Composong Feedback

extension AboutController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith _: MFMailComposeResult,
                               error _: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
