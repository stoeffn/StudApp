//
//  StudApp—Stud.IP to Go
//  Copyright © 2019, Steffen Ryll
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

import StudKit

final class LoggingController: UITableViewController {
    // MARK: - Life Cycle

    override func viewDidLayoutSubviews() {
        inMemoryLogSwitch.isOn = InMemoryLog.shared.isActive
        logTextView.text = InMemoryLog.shared.formattedLog
    }

    // MARK: - User Interface

    @IBOutlet var inMemoryLogSwitch: UISwitch!

    @IBOutlet var logTextView: UITextView!

    // MARK: - User Interaction

    @IBAction
    func inMemoryLogValueSwitchValueDidChange() {
        InMemoryLog.shared.isActive.toggle()
        view.setNeedsLayout()
    }

    @IBAction
    func didTapActionButton() {
        let controller = UIActivityViewController(activityItems: [InMemoryLog.shared.formattedLog], applicationActivities: [])
        controller.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(controller, animated: true, completion: nil)
    }
}
