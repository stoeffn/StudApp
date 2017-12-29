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
public final class BorderlessNavigationController: UINavigationController {
    // MARK: - Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        view.insertSubview(navigationBarBackgroundBlurView, belowSubview: navigationBar)
        view.insertSubview(navigationBarBackgroundAlphaView, belowSubview: navigationBar)

        updateLayout()

        usesDefaultAppearance = false
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateLayout()
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        /// Set the status bar background view, which makes for the blur effect, behind the status bar at all times.
        coordinator.animateAlongsideTransition(in: navigationController?.view, animation: { _ in
            self.updateLayout()
        }, completion: nil)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Oddly, you have to update the navigation bar background frame manually here when utilizing readable layout guide.
        updateLayout()
    }

    // MARK: - User Interface

    /// Any additional navigation bar height, e.g. due to a search bar.
    public var additionalHeight: CGFloat = 0 {
        didSet { updateLayout() }
    }

    public var toolBarView: UIView? {
        willSet {
            guard newValue != toolBarView else { return }
            toolBarView?.removeFromSuperview()
        }
        didSet {
            guard oldValue != toolBarView else { return }
            updateLayout()
            guard let toolBarView = toolBarView else { return }
            navigationBarBackgroundBlurView.contentView.addSubview(toolBarView)
        }
    }

    /// Whether to use the default navigation bar appearance with background and hairline.
    public var usesDefaultAppearance: Bool = false {
        didSet {
            navigationBarBackgroundBlurView.isHidden = usesDefaultAppearance
            navigationBarBackgroundAlphaView.isHidden = usesDefaultAppearance
            navigationBar.setBackgroundHidden(!usesDefaultAppearance)
            updateLayout()
        }
    }

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
        view.alpha = 0.5
        return view
    }()

    /// Proposed frame for the navigation bar background views, including the status bar and navigation bar frames.
    private var navigationBarBackgroundFrame: CGRect? {
        return navigationBar.subviews
            .map { $0.bounds }
            .min { $0.height > $1.height }
    }

    /// Update the navigation bar background views' frames. Needs to be called every time the layout changes.
    private func updateLayout() {
        guard let navigationBarFrame = navigationBarBackgroundFrame else { return }
        let toolBarViewHeight = toolBarView?.bounds.height ?? 0

        toolBarView?.frame = CGRect(x: 0, y: navigationBarFrame.height,
                                    width: navigationBarFrame.width, height: toolBarViewHeight)

        let backgroundHeight = navigationBarFrame.height + toolBarViewHeight + additionalHeight
        let backgroundSize = CGSize(width: navigationBarFrame.width, height: backgroundHeight)
        navigationBarBackgroundBlurView.frame = CGRect(origin: navigationBarFrame.origin, size: backgroundSize)
    }
}

// MARK: - Navigation Bar Delegate

extension BorderlessNavigationController: UINavigationControllerDelegate {
    public func navigationController(_: UINavigationController, didShow _: UIViewController, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.1 : 0) {
            self.updateLayout()
        }
    }
}
