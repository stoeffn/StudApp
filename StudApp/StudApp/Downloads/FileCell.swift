//
//  FileCell.swift
//  StudApp
//
//  Created by Steffen Ryll on 23.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class FileCell: UITableViewCell {
    // MARK: - Life Cycle

    var file: File! {
        didSet {
            iconView?.image = nil
            titleLabel?.text = file.title
            modificationDateLabel?.text = file.modifiedAt.formattedAsShortDifferenceFromNow
            sizeLabel?.text = file.size.formattedAsByteCount
            downloadCountLabel?.text = "%dx".localized(file.downloadCount)
            userGlyph.isHidden = file.owner == nil
            userLabel?.text = file.owner?.nameComponents.formatted()

            file.documentController { controller in
                self.iconView?.image = controller.icons.first
            }
        }
    }

    // MARK: - User Interface

    @IBOutlet weak var iconView: UIImageView?

    @IBOutlet weak var titleLabel: UILabel?

    @IBOutlet weak var modificationDateLabel: UILabel?

    @IBOutlet weak var sizeLabel: UILabel?

    @IBOutlet weak var downloadCountLabel: UILabel?

    @IBOutlet weak var userGlyph: UIImageView!

    @IBOutlet weak var userLabel: UILabel?

    // MARK: - User Interaction

    @objc
    func shareDocument(sender _: UIMenuController) {
        file.documentController { controller in
            controller.presentOptionsMenu(from: self.frame, in: self, animated: true)
        }
    }
}
