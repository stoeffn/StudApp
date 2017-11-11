//
//  CDCreatable.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public protocol CDCreatable {
    init(context: NSManagedObjectContext)

    init(createIn context: NSManagedObjectContext)
}

extension CDCreatable where Self: CDCreatable {
    public init(createIn context: NSManagedObjectContext) {
        self.init(context: context)
    }
}
