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

    var organization: OrganizationRecord! {
        didSet {
            titleLabel?.text = organization.title
            iconView?.image = organization.iconThumbnail
        }
    }

    // MARK: - User Interface

    @IBOutlet weak var iconView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
}
