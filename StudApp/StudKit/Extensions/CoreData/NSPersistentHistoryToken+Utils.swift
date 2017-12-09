//
//  NSPersistentHistoryToken+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@available(iOSApplicationExtension 11.0, *)
extension NSPersistentHistoryToken {
    /// Tries to decode a persistent history token from the data given.
    static func from(data: Data) -> NSPersistentHistoryToken? {
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        unarchiver.requiresSecureCoding = true
        let token = unarchiver.decodeObject(of: NSPersistentHistoryToken.self, forKey: NSKeyedArchiveRootObjectKey)
        unarchiver.finishDecoding()
        return token
    }

    /// Encodes this persistent history token as data.
    var data: Data {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.requiresSecureCoding = true
        archiver.finishEncoding()
        return data as Data
    }
}
