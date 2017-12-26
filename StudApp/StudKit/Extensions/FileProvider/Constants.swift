//
//  Constants.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import FileProvider

public let fileProviderFavoriteRankUnranked: Int = {
    guard #available(iOSApplicationExtension 11.0, *) else { return 1 }
    return Int(NSFileProviderFavoriteRankUnranked)
}()
