//
//  FileCell.swift
//  StudApp
//
//  Created by Steffen Ryll on 23.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class FileCell: UITableViewCell {
    private let reachabilityService = ServiceContainer.default[ReachabilityService.self]

    // MARK: - Life Cycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initObservers()
    }

    private func initObservers() {
        observer = NotificationCenter.default.addObserver(forName: .reachabilityDidChange, object: nil, queue: nil,
                                                          using: updateAvailability)
    }

    private var observer: NSObjectProtocol!

    var file: File! {
        didSet {
            accessoryType = file.isFolder ? .disclosureIndicator : .none

            if file.isFolder {
                iconView.image = #imageLiteral(resourceName: "FolderIcon")
            } else {
                iconView.image = nil
                file.documentController { self.iconView?.image = $0.icons.first }
            }

            titleLabel.text = file.title

            modifiedAtLabel?.text = file.modifiedAt.formattedAsShortDifferenceFromNow
            userLabel.text = file.owner?.nameComponents.formatted()
            sizeLabel.text = file.size.formattedAsByteCount
            downloadCountLabel.text = "%dx".localized(file.downloadCount)

            activityIndicator?.isHidden = !file.state.isDownloading
            downloadGlyph?.isHidden = !file.isDownloadable

            updateAvailability()
            updateSubtitleHiddenStates()
        }
    }

    // MARK: - User Interface

    override var frame: CGRect {
        didSet { updateSubtitleHiddenStates() }
    }

    @IBOutlet weak var iconView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var modifiedAtContainer: UIStackView!
    @IBOutlet weak var modifiedAtLabel: UILabel!

    @IBOutlet weak var userContainer: UIStackView!
    @IBOutlet weak var userLabel: UILabel!

    @IBOutlet weak var sizeContainer: UIStackView!
    @IBOutlet weak var sizeLabel: UILabel!

    @IBOutlet weak var downloadCountContainer: UIStackView!
    @IBOutlet weak var downloadCountLabel: UILabel!

    @IBOutlet weak var activityIndicator: StudIpActivityIndicatorView?
    @IBOutlet weak var downloadGlyph: UIImageView?

    func updateSubtitleHiddenStates() {
        guard let file = file else { return }
        userContainer.isHidden = file.owner == nil
        sizeContainer.isHidden = file.isFolder || frame.size.width < 512
        downloadCountContainer.isHidden = file.isFolder || frame.size.width < 512
    }

    private func updateAvailability(_: Notification? = nil) {
        UIView.animate(withDuration: 0.3) {
            self.contentView.alpha = self.file.isAvailable ? 1 : 0.6
        }
    }

    // MARK: - User Interaction

    @objc
    func share(_: Any?) {
        file.documentController { $0.presentOptionsMenu(from: self.frame, in: self, animated: true) }
    }

    @objc
    func remove(_: Any?) {
        try? file.removeDownload()
    }
}
