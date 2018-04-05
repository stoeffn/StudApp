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

import StudKit

public final class FileIconService {
    private lazy var iconCache = NSCache<NSURL, UIImage>()

    public func icon(for file: File, completion: @escaping (UIImage) -> Void) {
        guard !file.isFolder else { return completion(#imageLiteral(resourceName: "FolderIcon")) }

        let fileNameExtension = file.localUrl(in: .fileProvider).pathExtension
        let dummyFileName = BaseDirectories.fileProvider.url.appendingPathComponent("dummy.\(fileNameExtension)")

        if let icon = iconCache.object(forKey: dummyFileName as NSURL) { return completion(icon) }

        DispatchQueue.global(qos: .utility).async {
            let controller = UIDocumentInteractionController(url: dummyFileName)
            controller.name = dummyFileName.absoluteString

            guard let icon = controller.icons.first else { fatalError() }

            DispatchQueue.main.async {
                self.iconCache.setObject(icon, forKey: dummyFileName as NSURL)
                completion(icon)
            }
        }
    }
}
