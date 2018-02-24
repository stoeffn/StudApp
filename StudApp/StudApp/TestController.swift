//
//  TestController.swift
//  StudApp
//
//  Created by Steffen Ryll on 24.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import StudKit
import StudKitUI

final class TestController: UIViewController, Routable {
    private var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = user.nameComponents.formatted()
    }

    func prepareDependencies(for route: Routes) {
        guard case let .app(user) = route else { fatalError() }
        self.user = user
    }

    @IBOutlet weak var label: UILabel!
}
