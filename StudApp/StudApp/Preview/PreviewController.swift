//
//  PreviewController.swift
//  StudApp
//
//  Created by Steffen Ryll on 02.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import QuickLook
import StudKit

final class PreviewController: UIViewController, Routable {
    // MARK: - Life Cycle

    private var file: File!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = file.title

        previewController.dataSource = self
        addChildViewController(previewController)

        previewController.didMove(toParentViewController: self)
        previewController.view.frame = view.bounds
        view.addSubview(previewController.view)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        previewController.viewSafeAreaInsetsDidChange()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.previewController.view.frame = self.view.bounds
        }, completion: nil)
    }

    func prepareDependencies(for route: Routes) {
        guard case let .preview(file) = route else { fatalError() }

        self.file = file
    }

    // MARK: - User Interface

    private let previewController = QLPreviewController()

    // MARK: - User Interaction

    @IBAction
    func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension PreviewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in _: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_: QLPreviewController, previewItemAt _: Int) -> QLPreviewItem {
        return file
    }
}
