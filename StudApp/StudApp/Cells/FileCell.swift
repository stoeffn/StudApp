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
    private let contextService = ServiceContainer.default[ContextService.self]
    private let fileIconService = ServiceContainer.default[FileIconService.self]
    private let reachabilityService = ServiceContainer.default[ReachabilityService.self]

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
            titleLabel.numberOfLines = contextService.prefersAccessibilityContentSize ? 3 : 1

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

            let shareAction = UIAccessibilityCustomAction(name: "Share".localized, target: self, selector: #selector(share(_:)))
            let removeAction = UIAccessibilityCustomAction(name: "Remove".localized, target: self, selector: #selector(remove(_:)))

            accessibilityCustomActions = [shareAction, file.state.isDownloaded ? removeAction : nil].flatMap { $0 }
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
    func share(_: Any?) -> Bool {
        let controller = UIDocumentInteractionController(url: file.localUrl(in: .fileProvider))
        controller.name = file.title
        controller.presentOptionsMenu(from: frame, in: self, animated: true)
        return true
    }

    @objc
    func remove(_: Any?) -> Bool {
        do {
            try file.removeDownload()
            return true
        } catch {
            return false
        }
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
