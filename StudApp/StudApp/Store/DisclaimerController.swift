//
//  DisclaimerController.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKitUI

final class DisclaimerController: UIViewController, Routable {
    private var text: String!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        disclaimerLabel.text = text
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        preferredContentSize = containerView.bounds.size
    }

    // MARK: - Navigation

    func prepareContent(for route: Routes) {
        guard case let .disclaimer(text) = route else { fatalError() }
        self.text = text
    }

    // MARK: - User Interface

    @IBOutlet var containerView: UIView!

    @IBOutlet var disclaimerLabel: UILabel!

    // MARK: - User Interaction

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
}
