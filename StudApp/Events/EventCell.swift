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