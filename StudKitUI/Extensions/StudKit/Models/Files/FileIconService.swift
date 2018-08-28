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
    private lazy var iconForPathExtension = NSCache<NSString, UIImage>()
    private var isUpdatingIconForPathExtension = Set<String>()
    private var handlersForPathExtension = [String: [(UIImage) -> Void]]()

    public func icon(for file: File, completion: @escaping (UIImage) -> Void) {
        guard !file.isFolder else { return completion(#imageLiteral(resourceName: "FolderIcon")) }

        let pathExtension = file.localUrl(in: .fileProvider).pathExtension
        icon(forPathExtension: pathExtension, completion: completion)
    }

    public func icon(forPathExtension pathExtension: String, completion: @escaping (UIImage) -> Void) {
        if let icon = iconForPathExtension.object(forKey: pathExtension as NSString) {
            return completion(icon)
        }

        let isUpdating = isUpdatingIconForPathExtension.contains(pathExtension)
        isUpdatingIconForPathExtension.insert(pathExtension)
        handlersForPathExtension[pathExtension, default: []].append(completion)

        guard !isUpdating else { return }

        DispatchQueue.global(qos: .utility).async {
            let icon = self.icon(forPathExtension: pathExtension)

            DispatchQueue.main.async {
                self.iconForPathExtension.setObject(icon, forKey: pathExtension as NSString)
                self.handlersForPathExtension[pathExtension]?.forEach { $0(icon) }
                self.handlersForPathExtension[pathExtension]?.removeAll()
                self.isUpdatingIconForPathExtension.remove(pathExtension)
            }
        }
    }

    private func icon(forPathExtension pathExtension: String) -> UIImage {
        let dummyFileName = BaseDirectories.fileProvider.url.appendingPathComponent("dummy.\(pathExtension)")
        let controller = UIDocumentInteractionController(url: dummyFileName)
        controller.name = dummyFileName.absoluteString
        return controller.icons.first ?? #imageLiteral(resourceName: "FolderIcon")
    }
}
