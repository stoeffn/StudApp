//
//  ConfettiController.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 10.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

public final class ConfettiController: UIViewController, Routable {
    private var alert: UIAlertController!

    // MARK: - Life Cycle

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        present(alert, animated: true, completion: nil)
    }

    public func prepareDependencies(for route: Routes) {
        guard case let .confetti(alert) = route else { return }
        self.alert = alert
    }
}
