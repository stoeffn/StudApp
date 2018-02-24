//
//  FileIconService.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 24.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import StudKit

public final class FileIconService {
    private lazy var iconCache = NSCache<NSURL, UIImage>()

    public func icon(for url: URL, completion: @escaping (UIImage) -> Void) {
        guard !url.hasDirectoryPath else { return completion(#imageLiteral(resourceName: "FolderIcon")) }

        let fileName = URL(fileURLWithPath: url.lastPathComponent)

        if let icon = iconCache.object(forKey: fileName as NSURL) { return completion(icon) }

        DispatchQueue.global(qos: .background).async {
            let controller = UIDocumentInteractionController(url: fileName)
            controller.name = fileName.absoluteString

            guard let icon = controller.icons.first else { fatalError() }

            DispatchQueue.main.async {
                self.iconCache.setObject(icon, forKey: fileName as NSURL)
                completion(icon)
            }
        }
    }

    public func icon(for file: File, completion: @escaping (UIImage) -> Void) {
        icon(for: file.localUrl(in: .appGroup), completion: completion)
    }
}
