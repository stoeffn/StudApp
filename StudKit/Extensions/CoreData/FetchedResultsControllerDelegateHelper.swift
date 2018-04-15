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

public final class FetchedResultsControllerDelegateHelper: NSObject, NSFetchedResultsControllerDelegate {
    private weak var delegate: FetchedResultsControllerDelegate?

    public init(delegate: FetchedResultsControllerDelegate) {
        self.delegate = delegate
    }

    public func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        delegate?.controller(didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
    }

    public func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo,
                           atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        delegate?.controller(didChange: sectionInfo, atSectionIndex: sectionIndex, for: type)
    }

    public func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerWillChangeContent()
    }

    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerDidChangeContent()
    }
}
