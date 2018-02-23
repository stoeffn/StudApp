//
//  OrganizationCell.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 26.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class OrganizationCell: UITableViewCell {

    // MARK: - Life Cycle

    var organization: Organization! {
        didSet {
            titleLabel?.text = organization.title
            iconView?.image = organization.iconThumbnail
        }
    }

    // MARK: - User Interface

    @IBOutlet var iconView: UIImageView!

    @IBOutlet var titleLabel: UILabel!
}
