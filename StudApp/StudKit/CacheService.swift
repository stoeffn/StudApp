//
//  CacheService.swift
//  StudKit
//
//  Created by Steffen Ryll on 28.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

final public class CacheService {
    private lazy var documentInteractionControllers = NSCache<NSURL, UIDocumentInteractionController>()

    public func documentInteractionController(forUrl url: URL, name: String) -> UIDocumentInteractionController {
        if let controller = documentInteractionControllers.object(forKey: url as NSURL) {
            return controller
        }

        let controller = UIDocumentInteractionController(url: url)
        controller.name = name

        documentInteractionControllers.setObject(controller, forKey: url as NSURL)

        return controller
    }
}
