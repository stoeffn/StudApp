//
//  DocumentActionViewController.swift
//  StudFileProviderUI
//
//  Created by Steffen Ryll on 23.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import FileProviderUI
import StudKit

final class DocumentActionViewController: FPUIActionExtensionViewController {
    @IBOutlet weak var containerView: UIView!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        ServiceContainer.default.register(providers: StudKitServiceProvider(target: .fileProviderUI))
    }

    override func prepare(forAction actionIdentifier: String, itemIdentifiers: [NSFileProviderItemIdentifier]) {
        guard let action = ActionRoutes(actionIdentifier: actionIdentifier, context: extensionContext,
                                        itemIdentifiers: itemIdentifiers) else {
            fatalError("Cannot process unknown action with identifier '\(actionIdentifier)'.")
        }
        setViewController(for: action, itemIdentifiers: itemIdentifiers)
    }

    override func prepare(forError _: Error) {
        setViewController(for: .authenticate(context: extensionContext))
    }

    // MARK: - Helpers

    private func setViewController(for action: ActionRoutes, itemIdentifiers _: [NSFileProviderItemIdentifier] = []) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: action.identifier) else {
            fatalError("Cannot instantiate view controller with identifier '\(action.identifier)'.")
        }
        guard let routableController = (controller as? UINavigationController)?.childViewControllers.first as? Routable else {
            fatalError("View Controller does not conform to protocol '\(String(describing: Routable.self))'.")
        }
        routableController.prepareDependencies(for: action)
        addChildViewController(controller)
        containerView.addSubview(controller.view)
    }
}
