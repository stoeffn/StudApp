//
//  MainController.swift
//  StudApp
//
//  Created by Steffen Ryll on 07.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class MainController: UITabBarController {
    private var viewModel: MainViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = MainViewModel()
        viewModel.updateCurrentUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBar.items?[0].title = "Downloads".localized
        tabBar.items?[1].title = "Semesters".localized
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !viewModel.isSignedIn {
            performSegue(withRoute: Segues.chooseOrganization)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        prepareForRoute(using: segue, sender: sender)
    }

    // MARK: - User Interaction

    @IBAction
    func userButtonTapped(_ sender: Any) {
        func signOut(_: UIAlertAction) {
            viewModel.signOut()
            performSegue(withRoute: Segues.chooseOrganization)
        }

        guard let barButtonItem = sender as? UIBarButtonItem,
            let currentUser = viewModel.currentUser else { return }

        let title = "Signed in as %@".localized(currentUser.nameComponents.formatted(style: .long))
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        controller.popoverPresentationController?.barButtonItem = barButtonItem
        controller.addAction(UIAlertAction(title: "Sign Out".localized, style: .destructive, handler: signOut))
        controller.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
}