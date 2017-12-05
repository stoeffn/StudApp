//
//  SemesterState.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(SemesterState)
public final class SemesterState: NSManagedObject, CDCreatable {
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

        favoriteRank = Int(NSFileProviderFavoriteRankUnranked)
    }

    private func isHiddenChanged(_: _KeyValueCodingAndObserving, change: NSKeyValueObservedChange<Bool>) {
        guard let oldValue = change.oldValue, let newValue = change.newValue, newValue != oldValue else { return }

        try? managedObjectContext?.saveWhenChanged()

        NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
        NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
    }
}
