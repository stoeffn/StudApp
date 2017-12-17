//
//  DisclaimerController.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

final class DisclaimerController: UIViewController, Routable {
    private var text: String!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        disclaimerLabel.text = text
        disclaimerLabel.sizeToFit()

        preferredContentSize = containerView.bounds.size
    }

    func prepareDependencies(for route: Routes) {
        guard case let .disclaimer(text) = route else { fatalError() }
        self.text = text
    }

    // MARK: - User Interface

    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var disclaimerLabel: UILabel!

    // MARK: - User Interaction

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
}
