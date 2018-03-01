//
//  FileCell.swift
//  StudApp
//
//  Created by Steffen Ryll on 23.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit
import StudKitUI

final class FileCell: UITableViewCell {
    private let reachabilityService = ServiceContainer.default[ReachabilityService.self]
    private let fileIconService = ServiceContainer.default[FileIconService.self]

    // MARK: - Life Cycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initNotificationObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initNotificationObservers()
    }

    var file: File! {
        didSet {
            accessoryType = file.isFolder ? .disclosureIndicator : .none

            iconView.image = nil
            fileIconService.icon(for: file) { self.iconView?.image = $0 }

            titleLabel.text = file.title

            modifiedAtLabel?.text = file.modifiedAt.formattedAsShortDifferenceFromNow
            userLabel.text = file.owner?.nameComponents.formatted()
            sizeLabel.text = file.size.formattedAsByteCount
            downloadCountLabel.text = "%dx".localized(file.downloadCount)
            childrenCountLabel?.text = "%d items".localized(file.children.count)

            activityIndicator?.isHidden = file.isFolder || !file.state.isDownloading
            downloadGlyph?.isHidden = !file.isDownloadable

            updateSubtitleHiddenStates()
            updateReachabilityIndicator()
        }
    }

    // MARK: - User Interface

    override var frame: CGRect {
        didSet { updateSubtitleHiddenStates() }
    }

    @IBOutlet var iconView: UIImageView!

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var modifiedAtContainer: UIStackView!
    @IBOutlet var modifiedAtLabel: UILabel!

    @IBOutlet var userContainer: UIStackView!
    @IBOutlet var userLabel: UILabel!

    @IBOutlet var sizeContainer: UIStackView!
    @IBOutlet var sizeLabel: UILabel!

    @IBOutlet var downloadCountContainer: UIStackView!
    @IBOutlet var downloadCountLabel: UILabel!

    @IBOutlet var childrenCountContainer: UIStackView?
    @IBOutlet var childrenCountLabel: UILabel?

    @IBOutlet var activityIndicator: StudIpActivityIndicator?
    @IBOutlet var downloadGlyph: UIImageView?

    private func updateSubtitleHiddenStates() {
        guard let file = file else { return }
        sizeContainer.isHidden = file.size == -1
        downloadCountContainer.isHidden = file.downloadCount == -1 || frame.width < 512
        childrenCountContainer?.isHidden = !file.isFolder
        userContainer.isHidden = file.owner == nil || frame.width < 512
    }

    private func updateReachabilityIndicator() {
        UIView.animate(withDuration: UI.defaultAnimationDuration) {
            self.contentView.alpha = self.file.isAvailable ? 1 : 0.6
        }
    }

    // MARK: - Notifications

    private func initNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityDidChange(notification:)),
                                               name: .reachabilityDidChange, object: nil)
    }

    @objc
    private func reachabilityDidChange(notification _: Notification) {
        updateReachabilityIndicator()
    }

    // MARK: - User Interaction

    @objc
    func share(_: Any?) {
        let controller = UIDocumentInteractionController(url: file.localUrl(in: .fileProvider))
        controller.name = file.title
        controller.presentOptionsMenu(from: frame, in: self, animated: true)
    }

    @objc
    func remove(_: Any?) {
        try? file.removeDownload()
    }
}
