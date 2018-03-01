//
//  AnnouncementNavigationController.swift
//  StudApp
//
//  Created by Steffen Ryll on 01.03.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import StudKitUI

final class AnnouncementNavigationController: UINavigationController {
    // MARK: - Dismissal

    override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        guard presentedViewController != nil else { return }
        super.dismiss(animated: animated, completion: completion)
    }
}
