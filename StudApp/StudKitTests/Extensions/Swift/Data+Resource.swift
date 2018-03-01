//
//  Data+Resource.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import Foundation

extension Data {
    init(fromJsonResource filename: String) {
        guard let url = Bundle(for: Setup.self).url(forResource: filename, withExtension: "json") else {
            fatalError("Error getting file path for resource '\(filename)'.")
        }
        try! self.init(contentsOf: url)
    }
}
