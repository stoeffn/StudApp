//
//  Int+ByteCountFormatting.swift
//  StudApp
//
//  Created by Steffen Ryll on 20.02.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension Int {
    /// Formatted as a string containing the value as a byte count in a huma-readable format.
    public var formattedAsByteCount: String {
        return Int64(self).formattedAsByteCount
    }
}

public extension Int64 {
    /// Formatted as a string containing the value as a byte count in a huma-readable format.
    public var formattedAsByteCount: String {
        return ByteCountFormatter.string(fromByteCount: self, countStyle: .file)
    }
}
