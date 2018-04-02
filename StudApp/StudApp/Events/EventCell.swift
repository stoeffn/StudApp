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
            let startsAt = event.startsAt.formatted(using: .shortTime)
            let endsAt = event.endsAt.formatted(using: .shortTime)

            startsAtLabel.text = startsAt
            endsAtLabel.text = endsAt

            colorView.backgroundColor = event.course.color

            titleLabel.text = event.course.title

            cancellationContainer.isHidden = !event.isCanceled
            cancellationLabel.text = "Canceled".localized
            cancellationReasonLabel.isHidden = event.cancellationReason == nil
            cancellationReasonLabel.text = event.cancellationReason

            locationLabel.isHidden = event.isCanceled || event.location == nil
            locationLabel.text = event.location

            let fromToTimes = "from %@ to %@".localized(startsAt, endsAt)
            let atLocation = event.location != nil ? "at %@".localized(event.location ?? "") : nil
            let cancellation = event.isCanceled ? "Canceled".localized : nil
            accessibilityLabel = [event.course.title, fromToTimes, atLocation, cancellation, event.cancellationReason]
                .compactMap { $0 }
                .joined(separator: ", ")
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
        colorView.backgroundColor = event.course.color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        colorView.backgroundColor = event.course.color
    }
}
