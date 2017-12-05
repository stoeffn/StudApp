//
//  ColorCell.swift
//  StudSync
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    static let identifier = String(describing: ColorCell.self)

    // MARK: - Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        initUserInterface()
    }

    // MARK: - User Interface

    @IBOutlet weak var glowView: GlowView!

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
