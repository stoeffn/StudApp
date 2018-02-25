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

    public func icon(for file: File, completion: @escaping (UIImage) -> Void) {
        guard !file.isFolder else { return completion(#imageLiteral(resourceName: "FolderIcon")) }

        let fileNameExtension = file.localUrl(in: .fileProvider).pathExtension
        let dummyFileName = BaseDirectories.fileProvider.url.appendingPathComponent("dummy.\(fileNameExtension)")

        if let icon = iconCache.object(forKey: dummyFileName as NSURL) { return completion(icon) }

        DispatchQueue.global(qos: .background).async {
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
