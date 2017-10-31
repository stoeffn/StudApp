//
//  SignInNavigationController.swift
//  StudApp
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit

/// A custom navigation controller for the sign in flow that defaults to a transparent and borderless navigation bar and handles
/// keeping a light blur effect beneath the status bar in order to make it legible at all times.
final class SignInNavigationController : UINavigationController {
    /// A view with a light blur effect to be placed beneath the status bar. With no content behind it, it appears white and
    /// therefore blends with the background.
    let statusBarBackgroundView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.frame = UIApplication.shared.statusBarFrame
        return view
    }()
    
    // - MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.removeBackground()
        view.addSubview(statusBarBackgroundView)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        /// Set the status bar background view, which makes for the blur effect, behind the status bar at all times.
        coordinator.animateAlongsideTransition(in: navigationController?.view, animation: { context in
            self.statusBarBackgroundView.frame = UIApplication.shared.statusBarFrame
        }, completion: nil)
    }
}
