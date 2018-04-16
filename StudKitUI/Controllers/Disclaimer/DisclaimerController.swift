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

import StudKit

final class DisclaimerController: UIViewController, Routable {
    private var text: String!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        disclaimerView.text = text
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        preferredContentSize = containerView.bounds.size
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: UI.defaultAnimationDuration) {
            self.preferredContentSize = self.containerView.bounds.size
        }
    }

    func prepareContent(for route: Routes) {
        guard case let .disclaimer(text) = route else { fatalError() }
        self.text = text
    }

    // MARK: - User Interface

    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var disclaimerView: UITextView!

    // MARK: - User Interaction

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
}
