//
//  BorderlessNavigationController.swift
//  StudApp
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit

/// A custom navigation controller has a transparent and borderless navigation bar and handles keeping a light blur effect
/// beneath the status and navigation bar in order to make it legible at all times.
final class BorderlessNavigationController: UINavigationController {
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.removeBackground()

        view.insertSubview(navigationBarBackgroundBlurView, belowSubview: navigationBar)
        view.insertSubview(navigationBarBackgroundAlphaView, belowSubview: navigationBar)

        updateNavigationBarBackgroundFrame()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateNavigationBarBackgroundFrame()
    }

    override func viewWillTransition(to _: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        /// Set the status bar background view, which makes for the blur effect, behind the status bar at all times.
        coordinator.animateAlongsideTransition(in: navigationController?.view, animation: { _ in
            self.updateNavigationBarBackgroundFrame()
        }, completion: nil)
    }

    // MARK: - User Interface

    /// View with a light blur effect to be placed beneath the status and navigation bar. With no content behind it, it appears
    /// white and therefore blends in with the background.
    private let navigationBarBackgroundBlurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// Transparent, white view to be placed behind the navigation bar background blur view in order to dim the blur effect and
    /// make it less vibrant.
    private let navigationBarBackgroundAlphaView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.alpha = 0.4
        return view
    }()

    /// Proposed frame for the navigation bar background views, including the status bar and navigation bar frames.
    private var navigationBarBackgroundFrame: CGRect? {
        return navigationBar.subviews
            .map { $0.bounds }
            .min { $0.size.height > $1.size.height }
    }

    /// Update the navigation bar background views' frames. Needs to be called every time the layout changes.
    private func updateNavigationBarBackgroundFrame() {
        guard let frame = navigationBarBackgroundFrame else { return }
        navigationBarBackgroundBlurView.frame = frame
    }
}
