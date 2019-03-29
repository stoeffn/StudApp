//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

import CoreData

public protocol FetchedResultsControllerSource {
    associatedtype Object: NSFetchRequestResult

    associatedtype Row

    var fetchedResultControllerDelegateHelper: FetchedResultsControllerDelegateHelper { get }

    var controller: NSFetchedResultsController<Object> { get }

    func row(from object: Object) -> Row

    func object(from row: Row) -> Object
}

public extension FetchedResultsControllerSource {
    func row(from object: Object) -> Row {
        guard let row = object as? Row else { fatalError() }
        return row
    }

    func object(from row: Row) -> Object {
        guard let object = row as? Object else { fatalError() }
        return object
    }

    /// Fetches initial data.
    func fetch() {
        try? controller.performFetch()
    }
}
