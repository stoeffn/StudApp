//
//  FileProviderItemConvertibleState.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import Foundation

protocol FileProviderItemConvertibleState: class {
    var favoriteRank: Int { get set }
    var lastUsedDate: Date? { get set }
    var tagData: Data? { get set }
}
