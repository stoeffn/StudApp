//
//  ActionCell.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 29.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class ActionCell: UITableViewCell {
    // MARK: - Life Cycle

    public override func awakeFromNib() {
        super.awakeFromNib()

        actionButton.addTarget(self, action: #selector(actionButtonTapped(sender:)), for: .touchUpInside)
    }

    // MARK: - User Interface

    @IBOutlet public weak var titleLabel: UILabel!

    @IBOutlet public weak var subtitleLabel: UILabel!

    @IBOutlet public weak var actionButton: UIButton!

    // MARK: - User Interaction

    public var action: (() -> Void)?

    @objc
    private func actionButtonTapped(sender _: Any?) {
        action?()
    }
}
