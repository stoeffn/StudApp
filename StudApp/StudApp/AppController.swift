//
//  AppController.swift
//  StudApp
//
//  Created by Steffen Ryll on 23.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import StudKit
import StudKitUI

final class AppController: UIViewController {
    private var viewModel: AppViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = AppViewModel()

        view.backgroundColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentAppOrSignIn()
    }

    // MARK: - Supporting User Activities

    override func restoreUserActivityState(_ activity: NSUserActivity) {
        presentedViewController?.restoreUserActivityState(activity)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        prepareForRoute(using: segue, sender: sender)
    }

    @IBAction
    func unwindToApp(with _: UIStoryboardSegue) {
        presentAppOrSignIn()
    }

    @IBAction
    func unwindToAppAndSignOut(with _: UIStoryboardSegue) {
        viewModel.signOut()
    }

    private func presentAppOrSignIn() {
        if let user = User.current, viewModel.isSignedIn {
            performSegue(withRoute: .app(for: user))
        } else {
            performSegue(withRoute: .signIn)
        }
    }
}
