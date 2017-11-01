//
//  Int+NSNumber.swift
//  StudKit
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import Foundation

public extension Int {
    public var nsNumber: NSNumber {
        return NSNumber(value: self)
    }
}
