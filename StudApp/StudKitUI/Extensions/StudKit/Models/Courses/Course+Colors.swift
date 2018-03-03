//
//  Course+Colors.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 17.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import StudKit

public extension Course {
    public var color: UIColor {
        return UI.Colors.pickerColors[groupId]?.color ?? UI.Colors.studBlue
    }
}
