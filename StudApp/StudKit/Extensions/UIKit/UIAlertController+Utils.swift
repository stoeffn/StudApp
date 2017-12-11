//
//  UIAlertController+Utils.swift
//  StudApp
//
//  Created by Steffen Ryll on 22.02.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit

public extension UIAlertController {
    public convenience init(title: String, message: String? = nil) {
        self.init(title: title, message: message, preferredStyle: .alert)
        addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
    }

    public convenience init(confirmationWithTitle title: String, sourceView: UIView, sourceRect: CGRect,
                            handler: @escaping (UIAlertAction) -> Void) {
        self.init(title: nil, message: nil, preferredStyle: .actionSheet)
        addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        addAction(UIAlertAction(title: title, style: .destructive, handler: handler))
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = sourceRect
        popoverPresentationController?.permittedArrowDirections = [.up, .down]
    }
}
