//
//  CacheService.swift
//  StudKit
//
//  Created by Steffen Ryll on 28.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class CacheService {
    private lazy var documentInteractionControllers = NSCache<NSURL, UIDocumentInteractionController>()

    public func documentInteractionController(forUrl url: URL, name: String,
                                              handler: @escaping (UIDocumentInteractionController) -> Void) {
        if let controller = documentInteractionControllers.object(forKey: url as NSURL) {
            controller.name = name
            return handler(controller)
        }

        DispatchQueue.global(qos: .background).async {
            let controller = UIDocumentInteractionController(url: url)
            controller.name = name

            DispatchQueue.main.async {
                self.documentInteractionControllers.setObject(controller, forKey: url as NSURL)

                handler(controller)
            }
        }
    }
}
