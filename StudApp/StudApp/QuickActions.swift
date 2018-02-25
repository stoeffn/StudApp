//
//  QuickActions.swift
//  StudApp
//
//  Created by Steffen Ryll on 25.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

enum QuickActions: String {
    case presentCourses, presentDownloads

    init?(fromShortcutItemType shortcutItemType: String) {
        guard let identifier = shortcutItemType.components(separatedBy: ".").last else { return nil }
        self.init(rawValue: identifier)
    }
}
