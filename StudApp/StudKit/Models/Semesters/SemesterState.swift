//
//  SemesterState.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(SemesterState)
public final class SemesterState: NSManagedObject, CDCreatable, CDSortable {
    @NSManaged public var lastUsedAt: Date?

    @NSManaged public var favoriteRank: Int

    @NSManaged public var tagData: Data?

    @NSManaged public var isHidden: Bool

    @NSManaged public var isCollapsed: Bool

    @NSManaged public var areCoursesFetchedFromRemote: Bool

    @NSManaged public var semester: Semester

    var observations = [NSKeyValueObservation]()

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)

        observations.append(observe(\.isHidden, options: [.old, .new], changeHandler: isHiddenChanged))
    }

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)

        favoriteRank = fileProviderFavoriteRankUnranked
    }

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \SemesterState.semester.beginsAt, ascending: false),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<SemesterState: \(semester)>"
    }

    // MARK: - Events

    private func isHiddenChanged(_: _KeyValueCodingAndObserving, change: NSKeyValueObservedChange<Bool>) {
        guard
            let oldValue = change.oldValue,
            let newValue = change.newValue,
            newValue != oldValue
        else { return }

        try? managedObjectContext?.saveWhenChanged()

        if #available(iOSApplicationExtension 11.0, *) {
            NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }
    }
}
