//
//  FilledButton.swift
//  StudApp
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit

@IBDesignable
final class FilledButton : UIButton {
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUserInterface()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }
    
    // MARK: - User Interface
    
    private func initUserInterface() {
        layer.cornerRadius = 10
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                let alpha: CGFloat = self.isHighlighted ? 0.6 : 1
                self.alpha = alpha
                self.titleLabel?.alpha = alpha
            }, completion: nil)
        }
    }
}
