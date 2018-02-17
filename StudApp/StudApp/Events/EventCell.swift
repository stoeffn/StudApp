//
//  EventCell.swift
//  StudApp
//
//  Created by Steffen Ryll on 26.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit
import StudKitUI

final class EventCell: UITableViewCell {

    // MARK: - Life Cycle

    var event: Event! {
        didSet {
            startsAtLabel.text = event.startsAt.formatted(using: .shortTime)
            endsAtLabel.text = event.endsAt.formatted(using: .shortTime)

            colorView.backgroundColor = event.course.state.color

            titleLabel.text = event.course.title

            cancellationContainer.isHidden = !event.isCanceled
            cancellationLabel.text = "Canceled".localized
            cancellationReasonLabel.isHidden = event.cancellationReason == nil
            cancellationReasonLabel.text = event.cancellationReason

            locationLabel.isHidden = event.isCanceled || event.location == nil
            locationLabel.text = event.location
        }
    }

    // MARK: - User Interface

    @IBOutlet var startsAtLabel: UILabel!
    @IBOutlet var endsAtLabel: UILabel!

    @IBOutlet var colorView: UIView!

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var cancellationContainer: UIStackView!
    @IBOutlet var cancellationLabel: UILabel!
    @IBOutlet var cancellationReasonLabel: UILabel!

    @IBOutlet var locationLabel: UILabel!

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        colorView.backgroundColor = event.course.state.color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        colorView.backgroundColor = event.course.state.color
    }
}
