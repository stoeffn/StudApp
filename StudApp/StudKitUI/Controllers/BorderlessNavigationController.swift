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

import UIKit

/// A custom navigation controller has a transparent and borderless navigation bar and handles keeping a light blur effect
/// beneath the status and navigation bar in order to make it legible at all times.
public final class BorderlessNavigationController: UINavigationController {

    // MARK: - Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.insertSubview(navigationBarBackgroundBlurView, belowSubview: navigationBar)
        view.insertSubview(navigationBarBackgroundAlphaView, belowSubview: navigationBarBackgroundBlurView)

        updateLayout()
        updateAppearance()

        view.clipsToBounds = true
        usesDefaultAppearance = false

        NotificationCenter.default.addObserver(self, selector: #selector(reduceTransparencyDidChange(notification:)),
                                               name: .UIAccessibilityReduceTransparencyStatusDidChange, object: nil)
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
            guard oldValue != toolBarView, let toolBarView = toolBarView else { return }
            view.insertSubview(toolBarView, aboveSubview: navigationBarBackgroundBlurView)
            updateLayout()
        }
    }

    /// Whether to use the default navigation bar appearance with background and hairline.
    public var usesDefaultAppearance: Bool = false {
        didSet {
            updateAppearance()
            updateLayout()
        }
    }

    // Whether the navigation bar background view is hidden.
    public var isNavigationBarBackgroundHidden: Bool = false {
        didSet { updateAppearance() }
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
        return view
    }()

    /// Proposed frame for the navigation bar background views, including the status bar and navigation bar frames.
    private var navigationBarBackgroundFrame: CGRect? {
        return navigationBar.subviews
            .map { $0.bounds }
            .min { $0.height > $1.height }
    }

    /// Update the navigation bar background views' frames. Needs to be called every time the layout changes.
    public func updateLayout() {
        guard let navigationBarFrame = navigationBarBackgroundFrame else { return }

        let toolBarViewHeight = toolBarView?.bounds.height ?? 0
        let backgroundHeight = navigationBarFrame.height + toolBarViewHeight + additionalHeight
        let backgroundSize = CGSize(width: navigationBarFrame.width, height: backgroundHeight)
        let backgroundFrame = CGRect(origin: navigationBarFrame.origin, size: backgroundSize)

        navigationBarBackgroundAlphaView.frame = backgroundFrame
        navigationBarBackgroundBlurView.frame = backgroundFrame

        toolBarView?.frame = CGRect(x: 0, y: navigationBarFrame.height,
                                    width: navigationBarFrame.width, height: toolBarViewHeight)
    }

    private func updateAppearance() {
        let isTransparencyReduced = UIAccessibilityIsReduceTransparencyEnabled()
        navigationBarBackgroundBlurView.isHidden = isNavigationBarBackgroundHidden || usesDefaultAppearance || isTransparencyReduced
        navigationBarBackgroundAlphaView.isHidden = isNavigationBarBackgroundHidden || usesDefaultAppearance
        navigationBarBackgroundAlphaView.alpha = isTransparencyReduced ? 1 : 0.5
        navigationBar.setBackgroundHidden(!usesDefaultAppearance)
    }

    // MARK: - Notifications

    @objc private func reduceTransparencyDidChange(notification _: Notification) {
        updateAppearance()
    }
}
