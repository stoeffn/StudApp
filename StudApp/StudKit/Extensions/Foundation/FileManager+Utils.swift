//
//  FileManager+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension FileManager {
    func createIntermediateDirectories(forFileAt url: URL, attributes: [FileAttributeKey: Any]? = nil) throws {
        let directoryUrl = url.deletingLastPathComponent()
        try createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: attributes)
    }
}
