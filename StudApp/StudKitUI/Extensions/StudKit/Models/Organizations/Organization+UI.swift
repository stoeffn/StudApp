//
//  Organization+UI.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 23.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import StudKit

public extension Organization {
    var icon: UIImage? {
        guard let data = iconData else { return nil }
        return UIImage(data: data)
    }

    var iconThumbnail: UIImage? {
        guard let data = iconThumbnailData else { return nil }
        return UIImage(data: data)
    }
}
