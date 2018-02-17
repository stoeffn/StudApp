//
//  DocumentActionViewController.swift
//  StudFileProviderUI
//
//  Created by Steffen Ryll on 23.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import FileProviderUI
import StudKit
import StudKitUI

final class DocumentActionViewController: FPUIActionExtensionViewController {
    @IBOutlet var containerView: UIView!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        let provider = StudKitServiceProvider(currentTarget: .fileProviderUI, extensionContext: extensionContext)
        ServiceContainer.default.register(providers: provider)

        view.tintColor = UI.Colors.tint
    }

    override func prepare(forAction actionIdentifier: String, itemIdentifiers: [NSFileProviderItemIdentifier]) {
        guard let route = Routes(actionIdentifier: actionIdentifier, itemIdentifiers: itemIdentifiers) else {
            fatalError("Cannot process unknown action with identifier '\(actionIdentifier)'.")
        }
        setViewController(for: route, itemIdentifiers: itemIdentifiers)
    }

    override func prepare(forError error: Error) {
        guard let route = Routes(error: error) else {
            fatalError("Cannot process unknown error with description '\(error.localizedDescription)'.")
        }
        setViewController(for: route)
    }

    // MARK: - Helpers

    private func setViewController(for route: Routes, itemIdentifiers _: [NSFileProviderItemIdentifier] = []) {
        let destinationController = route.instantiateViewController()
        prepare(for: route, destination: destinationController)

        addChildViewController(destinationController)
        containerView.addSubview(destinationController.view)
    }
}
