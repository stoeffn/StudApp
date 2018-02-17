//
//  UIAlertController+Utils.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 22.02.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit

public extension UIAlertController {
    public convenience init(confirmationWithAction actionTitle: String?, sourceView: UIView, sourceRect: CGRect? = nil,
                            handler: @escaping (UIAlertAction) -> Void) {
        self.init(title: nil, message: nil, preferredStyle: .actionSheet)
        addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        addAction(UIAlertAction(title: actionTitle, style: .destructive, handler: handler))
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = sourceRect ?? sourceView.bounds
        popoverPresentationController?.permittedArrowDirections = [.up, .down]
    }
}
