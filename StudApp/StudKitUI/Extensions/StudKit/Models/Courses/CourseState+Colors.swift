//
//  CourseState+Colors.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 17.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import StudKit

public extension CourseState {
    public var color: UIColor {
        return UI.Colors.pickerColors[course.state.colorId] ?? UI.Colors.defaultPickerColor ?? UI.Colors.studBlue
    }
}
