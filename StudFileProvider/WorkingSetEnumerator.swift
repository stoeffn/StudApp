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
import StudKit

/// Enumerates all files, eg. semesters, courses or documents, that are currently considered important. This includes any
/// items marked as favorite, recently used items, and tagged items.
final class WorkingSetEnumerator: CachingFileProviderEnumerator {
    private let viewModels: [WorkingSetViewModel]

    // MARK: - Life Cycle

    /// Creates a new working set enumerator for items currently considered important.
    override init() {
        viewModels = [
            WorkingSetViewModel(fetchRequest: Course.workingSetFetchRequest as! NSFetchRequest<NSFetchRequestResult>),
            WorkingSetViewModel(fetchRequest: File.workingSetFetchRequest as! NSFetchRequest<NSFetchRequestResult>),
        ]

        super.init()

        for viewModel in viewModels {
            viewModel.delegate = cache
            viewModel.fetch()
        }
    }

    // MARK: - Providing Items

    override var items: [NSFileProviderItem] {
        return viewModels
            .flatMap { $0 }
            .map { $0.fileProviderItem }
    }
}
