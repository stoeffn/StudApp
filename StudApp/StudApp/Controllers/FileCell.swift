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

    var file: File? {
        didSet {
            guard let file = file else { return }

            documentController = UIDocumentInteractionController(url: file.localUrl)
            documentController?.name = file.title
            documentController?.presentPreview(animated: true)

            iconView?.image = documentController?.icons.last
            titleLabel?.text = file.title
            subtitleLabel?.text = file.owner?.familyName
        }
    }

    var documentController: UIDocumentInteractionController?

    // MARK: - User Interface

    @IBOutlet weak var iconView: UIImageView?

    @IBOutlet weak var titleLabel: UILabel?

    @IBOutlet weak var subtitleLabel: UILabel?
}
