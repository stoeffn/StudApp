//
//  ColorCell.swift
//  StudApp
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class ColorCell: UICollectionViewCell {

    // MARK: - Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        initUserInterface()
    }

    // MARK: - User Interface

    @IBOutlet var glowView: GlowView!

    private func initUserInterface() {
        clipsToBounds = false
    }

    var color: UIColor? {
        didSet {
            glowView.color = color
        }
    }

    override var isHighlighted: Bool {
        didSet {
            glowView.isHighlighted = isHighlighted
        }
    }
}
