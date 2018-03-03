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
            let modifiedAt = file.modifiedAt.formattedAsShortDifferenceFromNow
            let userFullname = file.owner?.nameComponents.formatted()
            let size = file.size.formattedAsByteCount

            accessoryType = file.isFolder ? .disclosureIndicator : .none

            iconView.image = nil
            fileIconService.icon(for: file) { self.iconView?.image = $0 }

            titleLabel.text = file.title

            modifiedAtLabel?.text = modifiedAt
            userLabel.text = userFullname
            sizeLabel.text = size
            downloadCountLabel.text = "%dx".localized(file.downloadCount)
            childCountLabel?.text = "%d items".localized(file.children.count)

            activityIndicator?.isHidden = !file.state.isDownloading
            downloadGlyph?.isHidden = !file.isDownloadable

            updateSubtitleHiddenStates()
            updateReachabilityIndicator()

            let modifiedBy = userFullname != nil ? "by %@".localized(userFullname ?? "") : nil
            let modifiedAtBy = ["Modified".localized, modifiedAt, modifiedBy].flatMap { $0 }.joined(separator: " ")
            let folderOrDocument = file.isFolder ? "Folder".localized : "Document".localized
            let sizeOrItemCount = file.isFolder ? "%d items".localized(file.children.count) : size
            accessibilityLabel = [folderOrDocument, file.title, modifiedAtBy, sizeOrItemCount].joined(separator: ", ")
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

    @IBOutlet var childCountContainer: UIStackView?
    @IBOutlet var childCountLabel: UILabel?

    @IBOutlet var activityIndicator: StudIpActivityIndicator?
    @IBOutlet var downloadGlyph: UIImageView?

    private func updateSubtitleHiddenStates() {
        guard let file = file else { return }
        sizeContainer.isHidden = file.size == -1
        downloadCountContainer.isHidden = file.downloadCount == -1 || frame.width < 512
        childCountContainer?.isHidden = !file.isFolder || file.state.childFilesUpdatedAt == nil
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

    // MARK: - Accessibility

    override var accessibilityValue: String? {
        get {
            guard !file.isFolder else { return nil }
            guard file.isAvailable else { return "Unavailable".localized }
            guard !file.state.isDownloading else { return "Downloading".localized }
            guard file.state.isDownloaded else { return "Not Downloaded".localized }
            return "Downloaded".localized
        }
        set {}
    }
}
