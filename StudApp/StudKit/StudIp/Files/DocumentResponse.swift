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
import MobileCoreServices

extension File.Location {
    init(rawLocation: String?, externalUrl: URL?) {
        switch rawLocation {
        case "disk", nil:
            self = .studIp
        case "url" where externalUrl != nil:
            self = .external
        default:
            self = .invalid
        }
    }
}

struct DocumentResponse: IdentifiableResponse {
    let id: String
    let location: File.Location
    let externalUrl: URL?
    let userId: String?
    let name: String
    let createdAt: Date
    let modifiedAt: Date
    let summary: String?
    let size: Int?
    let downloadCount: Int?

    init(id: String, location: File.Location = .invalid, externalUrl: URL? = nil, userId: String? = nil, name: String = "",
         createdAt: Date = .distantPast, modifiedAt: Date = .distantPast, summary: String? = nil, size: Int? = nil,
         downloadCount: Int? = nil) {
        self.id = id
        self.location = location
        self.externalUrl = externalUrl
        self.userId = userId
        self.name = name
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.summary = summary
        self.size = size
        self.downloadCount = downloadCount
    }
}

// MARK: - Coding

extension DocumentResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case location = "storage"
        case externalUrl = "url"
        case userId = "user_id"
        case name
        case createdAt = "mkdate"
        case modifiedAt = "chdate"
        case summary = "description"
        case size
        case downloadCount = "downloads"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        externalUrl = try? container.decode(URL.self, forKey: .externalUrl)
        location = File.Location(rawLocation: try? container.decode(String.self, forKey: .location), externalUrl: externalUrl)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)?.nilWhenEmpty
        name = try container.decode(String.self, forKey: .name)
        createdAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .createdAt)
        modifiedAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .modifiedAt)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)?.nilWhenEmpty
        size = Int(try container.decodeIfPresent(String.self, forKey: .size) ?? "")
        downloadCount = Int(try container.decodeIfPresent(String.self, forKey: .downloadCount) ?? "")
    }
}

// MARK: - Converting to a Core Data Object

extension DocumentResponse {
    @discardableResult
    func coreDataObject(course: Course, parent: File? = nil, in context: NSManagedObjectContext) throws -> File {
        let (document, _) = try File.fetch(byId: id, orCreateIn: context)
        document.location = location
        document.externalUrl = externalUrl
        document.organization = course.organization
        document.typeIdentifier = typeIdentifier
        document.course = course
        document.parent = parent ?? document.parent
        document.owner = try User.fetch(byId: userId, in: context)
        document.name = name
        document.createdAt = createdAt
        document.modifiedAt = modifiedAt
        document.size = size ?? -1
        document.downloadCount = downloadCount ?? -1
        document.summary = summary
        return document
    }

    var typeIdentifier: String {
        guard let fileExtension = name.components(separatedBy: ".").last else { return "" }
        let typeIdentifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
        return typeIdentifier?.takeRetainedValue() as String? ?? ""
    }
}
