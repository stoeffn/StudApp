//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

import MessageUI
import SafariServices
import StoreKit
import StudKit

final class AboutController: UITableViewController, Routable {
    private let htmlContentService = ServiceContainer.default[HtmlContentService.self]
    private var viewModel: AboutViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "About".localized

        tableView.register(ThanksNoteCell.self, forCellReuseIdentifier: ThanksNoteCell.typeIdentifier)

        switch Distributions.current {
        case .debug, .uiTest, .testFlight:
            titleLabel.text = "\(App.name) \(App.versionName) (\(App.version))"
            distributionLabel.isHidden = false
        case .appStore:
            titleLabel.text = "\(App.name) \(App.versionName)"
            distributionLabel.isHidden = true
        }

        distributionLabel.text = Distributions.current.description
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

    @IBOutlet var distributionLabel: UILabel!

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
            return "I would appreciate your review on the App Store!".localized
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
            guard let controller = htmlContentService.safariViewController(for: App.Urls.website) else { break }
            present(controller, animated: true, completion: nil)
        case .links? where cell === privacyCell:
            guard let controller = htmlContentService.safariViewController(for: App.Urls.privacyPolicy) else { break }
            present(controller, animated: true, completion: nil)
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
            guard
                let url = viewModel[rowAt: indexPath.row].url,
                let controller = htmlContentService.safariViewController(for: url)
            else { break }
            present(controller, animated: true, completion: nil)
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
        Targets.current.open(url: App.Urls.review) { success in
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
                    self.presentedViewController?.dismiss(animated: true) {
                        guard #available(iOSApplicationExtension 10.3, *) else { return }
                        SKStoreReviewController.requestReview()
                    }
                }
            })
            performSegue(withRoute: .confetti(alert: controller))
        case .failed:
            navigationItem.setActivityIndicatorHidden(true)

            let title = transaction.error?.localizedDescription ?? "Something Went Wrong".localized
            let message = "It would be kind if you retried in a little bit.".localized
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
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
