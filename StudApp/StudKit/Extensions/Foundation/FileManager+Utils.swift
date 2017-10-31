//
//  FileManager+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension FileManager {
    func createIntermediateDirectories(forFileAt fileUrl: URL, attributes: [FileAttributeKey: Any]? = nil) throws {
        let url = fileUrl.deletingLastPathComponent()
        try createDirectory(at: url, withIntermediateDirectories: true, attributes: attributes)
    }
}
