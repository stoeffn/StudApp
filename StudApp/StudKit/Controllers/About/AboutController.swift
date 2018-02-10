//
//  AboutController.swift
//  StudApp
//
//  Created by Steffen Ryll on 28.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import MessageUI
import SafariServices

final class AboutController: UITableViewController, Routable {
    private let contextService = ServiceContainer.default[ContextService.self]
    private var viewModel: AboutViewModel!
    private var completionHandler: (() -> Void)?

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = AboutViewModel()

        navigationItem.title = "About".localized

        tableView.register(ThanksNoteCell.self, forCellReuseIdentifier: ThanksNoteCell.typeIdentifier)

        if let appName = App.name, let appVersionName = App.versionName {
            titleLabel.text = "\(appName) \(appVersionName)"
        }
        subtitleLabel.text = "by %@".localized(App.authorName)

        websiteCell.textLabel?.text = "Website".localized
        privacyCell.textLabel?.text = "Privacy Policy".localized

        sendFeedbackCell.textLabel?.text = "Send Feedback".localized
        rateAppCell.textLabel?.text = "Rate StudApp".localized
    }

    func prepareDependencies(for route: Routes) {
        guard case let .about(handler) = route else { fatalError() }
        completionHandler = handler
    }

    // MARK: - User Interface

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var websiteCell: UITableViewCell!

    @IBOutlet weak var privacyCell: UITableViewCell!

    @IBOutlet weak var sendFeedbackCell: UITableViewCell!

    @IBOutlet weak var rateAppCell: UITableViewCell!

    // MARK: - User Interaction

    @IBAction
    func doneButtonTapped(_: Any) {
        completionHandler?()
    }

    @IBAction
    func actionButtonTapped(_: Any) {
        guard let appUrl = App.Links.appStore else { return }

        let controller = UIActivityViewController(activityItems: [appUrl], applicationActivities: nil)
        controller.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(controller, animated: true, completion: nil)
    }

    // MARK: - Table View Data Source

    private enum Sections: Int {
        case app, links, feedback, thanks
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .thanks?:
            return viewModel.numberOfRows
        case .app?, .links?, .feedback?, nil:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .thanks?:
            let cell = tableView.dequeueReusableCell(withIdentifier: ThanksNoteCell.typeIdentifier, for: indexPath)
            (cell as? ThanksNoteCell)?.thanksNote = viewModel[rowAt: indexPath.row]
            return cell
        case .app?, .links?, .feedback?, nil:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .thanks?:
            return "Thanks to".localized
        case .app?, .links?, .feedback?, nil:
            return nil
        }
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .feedback?:
            return "We would appreciate your review on the App Store!".localized
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
        case .thanks?:
            openInSafari(viewModel[rowAt: indexPath.row].url)
        case .links? where cell === websiteCell:
            openInSafari(App.Links.website)
        case .links? where cell === privacyCell:
            openInSafari(App.Links.privacyPolicy)
        case .feedback? where cell === sendFeedbackCell:
            openFeedbackMailComposer()
            tableView.deselectRow(at: indexPath, animated: true)
        case .feedback? where cell === rateAppCell:
            openAppStoreReviewPage()
            tableView.deselectRow(at: indexPath, animated: true)
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
            UIPasteboard.general.url = App.Links.website
        case .links? where cell === privacyCell:
            UIPasteboard.general.url = App.Links.privacyPolicy
        case .feedback? where cell === sendFeedbackCell:
            UIPasteboard.general.string = App.feedbackMailAddress
        case .feedback? where cell === rateAppCell:
            UIPasteboard.general.url = App.Links.review
        case .thanks?:
            UIPasteboard.general.url = viewModel[rowAt: indexPath.row].url
        default:
            fatalError()
        }
    }

    // MARK: - Helpers

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
        mailController.setSubject("Feedback for %@".localized(titleLabel.text ?? "App"))

        if MFMailComposeViewController.canSendMail() {
            present(mailController, animated: true, completion: nil)
        }
    }

    private func openAppStoreReviewPage() {
        guard let reviewUrl = App.Links.review else { return }

        contextService.openUrl?(reviewUrl) { success in
            guard !success else { return }

            let title = "Could not launch App Store".localized
            let message = "It would be kind if you rated StudApp anyway by opening the App Store manually.".localized
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay".localized, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Mail Composer

extension AboutController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith _: MFMailComposeResult,
                               error _: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
