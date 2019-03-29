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
    init(rawLocation: String?, externalUrl: URL?, mimeType: String?) {
        switch rawLocation {
        case "disk", nil:
            self = .studIp
        case "url" where externalUrl != nil && mimeType == "application/octet-stream":
            self = .website
        case "url" where externalUrl != nil:
            self = .external
        default:
            self = .invalid
        }
    }
}

struct DocumentResponse: IdentifiableResponse {
    static let extensionDelimiter = "."

    let id: String
    let location: File.Location
    let externalUrl: URL?
    let userId: String?
    let name: String
    let mimeType: String?
    let createdAt: Date
    let modifiedAt: Date
    let summary: String?
    let size: Int?
    let downloadCount: Int?

    init(id: String, location: File.Location = .invalid, externalUrl: URL? = nil, userId: String? = nil, name: String = "",
         mimeType: String? = nil, createdAt: Date = .distantPast, modifiedAt: Date = .distantPast, summary: String? = nil,
         size: Int? = nil, downloadCount: Int? = nil) {
        self.id = id
        self.location = location
        self.externalUrl = externalUrl
        self.userId = userId
        self.name = name
        self.mimeType = mimeType
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
        case mimeType = "mime_type"
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
        mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
        location = File.Location(rawLocation: try? container.decode(String.self, forKey: .location),
                                 externalUrl: externalUrl, mimeType: mimeType)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)?.nilWhenEmpty
        name = try container.decode(String.self, forKey: .name)
        createdAt = try StudIp.decodeDate(in: container, forKey: .createdAt)
        modifiedAt = try StudIp.decodeDate(in: container, forKey: .modifiedAt)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)?.nilWhenEmpty
        size = try? container.decodeIfPresent(Int.self, forKey: .size)
            ?? Int(try container.decodeIfPresent(String.self, forKey: .size) ?? "")
        downloadCount = try? container.decodeIfPresent(Int.self, forKey: .downloadCount)
            ?? Int(try container.decodeIfPresent(String.self, forKey: .downloadCount) ?? "")
    }
}

// MARK: - Converting to a Core Data Object

extension DocumentResponse {
    @discardableResult
    func coreDataObject(course: Course, parent: File? = nil, in context: NSManagedObjectContext) throws -> File {
        let (document, isNew) = try File.fetch(byId: id, orCreateIn: context)
        document.location = location
        document.externalUrl = externalUrl
        document.organization = course.organization
        document.typeIdentifier = typeIdentifier ?? ""
        document.course = course
        document.parent = parent ?? document.parent
        document.owner = try User.fetch(byId: userId, in: context)
        document.name = extendedName
        document.createdAt = createdAt
        document.isNew = StudIp.isNew(wasNew: document.isNew, locallyModifiedAt: isNew ? nil : document.modifiedAt,
                                      modifiedAt: modifiedAt)
        document.modifiedAt = modifiedAt
        document.size = Int64(size ?? -1)
        document.downloadCount = Int64(downloadCount ?? -1)
        document.summary = summary
        return document
    }

    var extendedName: String {
        guard location != .website else { return "\(name)\(DocumentResponse.extensionDelimiter)url" }

        guard
            !name.contains(DocumentResponse.extensionDelimiter),
            let typeIdentifier = typeIdentifier,
            let `extension` = UTTypeCopyPreferredTagWithClass(typeIdentifier as CFString, kUTTagClassFilenameExtension)
        else { return name }

        return "\(name)\(DocumentResponse.extensionDelimiter)\(`extension`.takeRetainedValue())"
    }

    var typeIdentifier: String? {
        guard location != .website else { return kUTTypeURL as String }

        guard let mimeType = mimeType else {
            guard let fileExtension = name.components(separatedBy: DocumentResponse.extensionDelimiter).last else { return nil }

            let typeIdentifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
            return typeIdentifier?.takeRetainedValue() as String?
        }

        let typeIdentifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)
        return typeIdentifier?.takeRetainedValue() as String?
    }
}
