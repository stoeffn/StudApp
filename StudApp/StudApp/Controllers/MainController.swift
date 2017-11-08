//
//  MainController.swift
//  StudApp
//
//  Created by Steffen Ryll on 07.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit

class MainController : UITabBarController {
    // MARK: - Life Cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        performSegue(withRoute: Segues.signIn)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        prepare(for: Segues.signIn, destination: segue.destination)
    }
}
