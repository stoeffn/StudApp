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

public enum BaseDirectories {
    case appGroup

    case downloads

    case fileProvider

    public var url: URL {
        switch self {
        case .appGroup:
            let identifier = App.groupIdentifier
            guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
                fatalError("Cannot create URL for app group directory with identifier '\(identifier)'.")
            }
            return url
        case .downloads:
            return BaseDirectories.appGroup.url.appendingPathComponent("Downloads", isDirectory: true)
        case .fileProvider:
            guard #available(iOSApplicationExtension 11.0, *) else { return BaseDirectories.downloads.url }
            return NSFileProviderManager.default.documentStorageURL
        }
    }

    public func containerUrl(forObjectId objectId: ObjectIdentifier) -> URL {
        return url.appendingPathComponent(objectId.rawValue, isDirectory: true)
    }
}
