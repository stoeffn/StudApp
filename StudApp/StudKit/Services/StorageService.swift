//
//  StorageService.swift
//  StudKit
//
//  Created by Steffen Ryll on 29.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

final public class StorageService {
    lazy var documentsUrl: URL = {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let path = paths.first else {
            fatalError("Cannot construct default documents directory URL.")
        }
        return URL(fileURLWithPath: path)
    }()
}
