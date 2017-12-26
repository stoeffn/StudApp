//
//  EventCell.swift
//  StudApp
//
//  Created by Steffen Ryll on 26.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class EventCell: UITableViewCell {
    // MARK: - Life Cycle

    var event: Event! {
        didSet {
            colorView.backgroundColor = event.course.state.color
        }
    }

    // MARK: - User Interface

    @IBOutlet weak var colorView: UIView!

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        colorView.backgroundColor = event.course.state.color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        colorView.backgroundColor = event.course.state.color
    }
}
