//
//  FetchedResultsControllerSource.swift
//  StudKit
//
//  Created by Steffen Ryll on 29.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

protocol FetchedResultsControllerSource {
    associatedtype Object: NSFetchRequestResult

    associatedtype Row

    var fetchedResultControllerDelegateHelper: FetchedResultsControllerDelegateHelper { get }

    var controller: NSFetchedResultsController<Object> { get }

    func row(from object: Object) -> Row

    func object(from row: Row) -> Object
}

extension FetchedResultsControllerSource {
    func row(from object: Object) -> Row {
        guard let row = object as? Row else { fatalError() }
        return row
    }

    func object(from row: Row) -> Object {
        guard let object = row as? Object else { fatalError() }
        return object
    }

    /// Fetches initial data.
    public func fetch() {
        try? controller.performFetch()
    }
}
