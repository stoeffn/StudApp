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

    // MARK: - Navigation

    @IBAction
    func unwindToApp(with _: UIStoryboardSegue) {
        let contextService: ServiceContainer.default[ContextService.self]
        contextService.extensionContext?.completeRequest(returningItems: nil) { _ in
            NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
        }
    }

    // MARK: - Helpers

    private func setViewController(for route: Routes, itemIdentifiers _: [NSFileProviderItemIdentifier] = []) {
        let destinationController = route.instantiateViewController()
        prepare(for: route, destination: destinationController)

        addChildViewController(destinationController)
        containerView.addSubview(destinationController.view)
    }
}
