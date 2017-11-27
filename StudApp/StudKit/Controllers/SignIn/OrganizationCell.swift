//
//  OrganizationCell.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit

final class OrganizationCell: UITableViewCell {
    // MARK: - Life Cycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUserInterface()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    var organization: OrganizationRecord? {
        didSet {
            textLabel?.text = organization?.title
            imageView?.image = organization?.iconThumbnail
        }
    }

    // MARK: - User Interface

    override func layoutSubviews() {
        super.layoutSubviews()

        let inset = UI.defaultCornerRadius / 2
        guard let imageFrame = imageView?.frame.insetBy(dx: inset, dy: inset) else { return }
        imageView?.frame = imageFrame
    }

    private func initUserInterface() {
        imageView?.layer.cornerRadius = UI.defaultCornerRadius / 2
    }
}
