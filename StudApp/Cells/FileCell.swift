//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

import StudKit
import StudKitUI

final class FileCell: UITableViewCell {
    private let fileIconService = ServiceContainer.default[FileIconService.self]
    private let reachabilityService = ServiceContainer.default[ReachabilityService.self]

    // MARK: - Life Cycle

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUserInterface()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    var file: File! {
        didSet {
            let modifiedAt = file.modifiedAt.formattedAsShortDifferenceFromNow
            let userFullname = file.owner?.nameComponents.formatted()
            let size = file.size.formattedAsByteCount
            let host = file.externalUrl?.host

            accessoryType = file.isFolder || !file.isLocationSecure ? .disclosureIndicator : .none

            iconView.image = nil
            fileIconService.icon(for: file) { self.iconView?.image = $0 }

            titleLabel.text = file.title
            titleLabel.numberOfLines = Targets.current.prefersAccessibilityContentSize ? 3 : 1

            modifiedAtLabel?.text = modifiedAt
            userLabel.text = userFullname
            sizeLabel.text = size
            hostLabel.text = host
            downloadCountLabel.text = "%dx".localized(file.downloadCount)
            childCountLabel?.text = "%d items".localized(file.children.count)

            activityIndicator?.isHidden = !file.state.isDownloading
            downloadGlyph?.isHidden = !file.isDownloadable || !file.isLocationSecure

            updateSubtitleHiddenStates()
            updateReachabilityIndicator()

            let modifiedBy = userFullname != nil ? "by %@".localized(userFullname ?? "") : nil
            let modifiedAtBy = ["Modified".localized, modifiedAt, modifiedBy].compactMap { $0 }.joined(separator: " ")
            let folderOrDocument = file.isFolder ? "Folder".localized : "Document".localized
            let sizeOrItemCount = file.isFolder ? "%d items".localized(file.children.count) : size
            let hostedBy = file.location == .external ? "hosted by %@".localized(host ?? "") : nil

            accessibilityLabel = [
                folderOrDocument, file.title, modifiedAtBy, sizeOrItemCount, hostedBy,
            ].compactMap { $0 }.joined(separator: ", ")

            let shareAction = UIAccessibilityCustomAction(name: "Share".localized, target: self, selector: #selector(share(_:)))
            let removeAction = UIAccessibilityCustomAction(name: "Remove".localized, target: self, selector: #selector(remove(_:)))

            accessibilityCustomActions = [shareAction, file.state.isDownloaded ? removeAction : nil].compactMap { $0 }
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

    @IBOutlet var hostContainer: UIStackView!
    @IBOutlet var hostLabel: UILabel!

    @IBOutlet var downloadCountContainer: UIStackView!
    @IBOutlet var downloadCountLabel: UILabel!

    @IBOutlet var childCountContainer: UIStackView?
    @IBOutlet var childCountLabel: UILabel?

    @IBOutlet var activityIndicator: StudIpActivityIndicator?
    @IBOutlet var downloadGlyph: UIImageView?

    private func initUserInterface() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityDidChange(notification:)),
                                               name: .reachabilityDidChange, object: nil)
    }

    private func updateSubtitleHiddenStates() {
        guard let file = file else { return }
        sizeContainer.isHidden = file.size <= 0
        hostContainer.isHidden = file.location != .external
        downloadCountContainer.isHidden = file.downloadCount <= 0 || frame.width < 512
        childCountContainer?.isHidden = !file.isFolder || file.state.childFilesUpdatedAt == nil
        userContainer.isHidden = file.owner == nil || frame.width < 512
    }

    private func updateReachabilityIndicator() {
        UIView.animate(withDuration: UI.defaultAnimationDuration) {
            self.contentView.alpha = self.file.isAvailable ? 1 : 0.5
        }
    }

    // MARK: - Notifications

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
