//
//  FetchedResultsControllerDelegate.swift
//  StudKit
//
//  Created by Steffen Ryll on 29.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

protocol FetchedResultsControllerDelegate: class {
    func controller(didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?)

    func controller(didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType)

    func controllerWillChangeContent()

    func controllerDidChangeContent()
}
