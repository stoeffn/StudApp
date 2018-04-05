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

import CloudKit
import CoreData

public struct OrganizationRecord {
    enum Keys: String {
        case apiUrl, consumerKey, consumerSecret, title, iconThumbnail, icon
    }

    let id: String
    let apiUrl: URL
    let title: String

    init(id: String, apiUrl: URL? = nil, title: String = "") {
        self.id = id
        self.apiUrl = apiUrl ?? URL(string: "localhost")!
        self.title = title
    }
}

extension OrganizationRecord {
    init?(from record: CKRecord) {
        guard record.recordType.lowercased() == Organization.recordType,
            let apiUrlString = record[Keys.apiUrl.rawValue] as? String,
            let apiUrl = URL(string: apiUrlString),
            let title = record[Keys.title.rawValue] as? String
        else { return nil }

        id = record.recordID.recordName
        self.apiUrl = apiUrl
        self.title = title
    }
}

extension OrganizationRecord {
    @discardableResult
    func coreDataObject(in context: NSManagedObjectContext) throws -> Organization {
        let (organization, _) = try Organization.fetch(byId: id, orCreateIn: context)
        organization.title = title
        organization.apiUrl = apiUrl
        return organization
    }
}
