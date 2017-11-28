//
//  AboutController.swift
//  StudApp
//
//  Created by Steffen Ryll on 28.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import MessageUI
import SafariServices
import StudKit

final class AboutController: UITableViewController, Routable {
    private var viewModel: AboutViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = AboutViewModel()

        navigationItem.title = "About".localized

        tableView.register(ThanksNoteCell.self, forCellReuseIdentifier: ThanksNoteCell.typeIdentifier)

        if let appName = viewModel.appName, let appVersionName = viewModel.appVersionName {
            titleLabel.text = "\(appName) \(appVersionName)"
        }
        subtitleLabel.text = "by %@".localized(viewModel.appAuthorName)
        sendFeedbackCell.textLabel?.text = "Send Feedback".localized
    }

    // MARK: - User Interface

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var sendFeedbackCell: UITableViewCell!

    // MARK: - User Interaction

    @IBAction
    func doneButtonTapped(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table View Data Source

    private enum Sections: Int {
        case app, feedback, thanks
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .thanks?:
            return viewModel.numberOfRows
        case .app?, .feedback?, nil:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .thanks?:
            let cell = tableView.dequeueReusableCell(withIdentifier: ThanksNoteCell.typeIdentifier, for: indexPath)
            (cell as? ThanksNoteCell)?.thanksNote = viewModel[rowAt: indexPath.row]
            return cell
        case .app?, .feedback?, nil:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .thanks?:
            return "Thanks to".localized
        case .app?, .feedback?, nil:
            return nil
        }
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .thanks?:
            return "Without you, this app could not exist. Thank you ❤️".localized
        case .app?, .feedback?, nil:
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
        switch Sections(rawValue: indexPath.section) {
        case .thanks?:
            guard let url = viewModel[rowAt: indexPath.row].url else { return }
            let safariController = SFSafariViewController(url: url)
            present(safariController, animated: true, completion: nil)
        case .feedback?:
            openFeedbackMailComposer()
        case .app?, nil:
            break
        }
    }

    override func tableView(_: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath,
                            withSender _: Any?) -> Bool {
        switch Sections(rawValue: indexPath.section) {
        case .feedback?:
            return action == #selector(copy(_:))
        case .thanks?:
            guard viewModel[rowAt: indexPath.row].url != nil else { return false }
            return action == #selector(copy(_:))
        case .app?, nil:
            return false
        }
    }

    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath,
                            withSender _: Any?) {
        switch Sections(rawValue: indexPath.section) {
        case .feedback?:
            UIPasteboard.general.string = App.feedbackMailAddress
        case .thanks?:
            UIPasteboard.general.url = viewModel[rowAt: indexPath.row].url
        case .app?, nil:
            break
        }
    }

    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        switch Sections(rawValue: indexPath.section) {
        case .feedback?:
            return true
        case .thanks?:
            return viewModel[rowAt: indexPath.row].url != nil
        case .app?, nil:
            return false
        }
    }

    // MARK: - Helpers

    private func openFeedbackMailComposer() {
        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        mailController.setToRecipients([App.feedbackMailAddress])
        mailController.setSubject("Feedback for %@".localized(titleLabel.text ?? "App"))

        if MFMailComposeViewController.canSendMail() {
            present(mailController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Cannot Open Email Composer".localized,
                                          message: "Please check whether you configured an email account.".localized,
                                          preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
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
