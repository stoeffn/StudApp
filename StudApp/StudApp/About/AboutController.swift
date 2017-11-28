//
//  AboutController.swift
//  StudApp
//
//  Created by Steffen Ryll on 28.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

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
        subtitleLabel.text = "by %@".localized("Steffen Ryll")
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

    private let thanksSectionIndex = 2

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case thanksSectionIndex:
            return viewModel.numberOfRows
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case thanksSectionIndex:
            let cell = tableView.dequeueReusableCell(withIdentifier: ThanksNoteCell.typeIdentifier, for: indexPath)
            (cell as? ThanksNoteCell)?.thanksNote = viewModel[rowAt: indexPath.row]
            return cell
        default:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case thanksSectionIndex: return "Thanks to".localized
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case thanksSectionIndex: return "Without you, this app could not exist. Thank you ❤️".localized
        default: return nil
        }
    }

    // MARK: Table View Delegate

    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        // Needs to be overridden in order to avoid index-out-of-range-exceptions caused by static cells.
        switch indexPath.section {
        case thanksSectionIndex:
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case thanksSectionIndex:
            guard let url = viewModel[rowAt: indexPath.row].url else { return }
            let safariController = SFSafariViewController(url: url)
            present(safariController, animated: true, completion: nil)
        default:
            break
        }
    }
}
