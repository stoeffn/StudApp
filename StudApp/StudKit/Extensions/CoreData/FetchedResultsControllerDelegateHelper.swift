//
//  FetchedResultsController.swift
//  StudKit
//
//  Created by Steffen Ryll on 29.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

final class FetchedResultsControllerDelegateHelper: NSObject, NSFetchedResultsControllerDelegate {
    private weak var delegate: FetchedResultsControllerDelegate?

    init(delegate: FetchedResultsControllerDelegate) {
        self.delegate = delegate
    }

    func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        delegate?.controller(didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
    }

    func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        delegate?.controller(didChange: sectionInfo, atSectionIndex: sectionIndex, for: type)
    }

    func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerWillChangeContent()
    }

    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerDidChangeContent()
    }
}
