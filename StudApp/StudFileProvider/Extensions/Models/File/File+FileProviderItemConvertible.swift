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

extension File: FileProviderItemConvertible {
    public var itemState: FileProviderItemConvertibleState {
        return state
    }

    public var fileProviderItem: NSFileProviderItem {
        return FileItem(from: self)
    }

    public func provide(at url: URL, completion: ((Error?) -> Void)?) {
        guard !isFolder else {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                completion?(nil)
            } catch {
                completion?(error)
            }
            return
        }

        download { result in
            guard result.isSuccess else {
                completion?(NSFileProviderError(.serverUnreachable))
                return
            }

            do {
                try? FileManager.default.removeItem(at: url)
                try FileManager.default.createIntermediateDirectories(forFileAt: url)
                try FileManager.default.copyItem(at: self.localUrl(in: .downloads), to: url)
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }
}
