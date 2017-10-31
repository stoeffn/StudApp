//
//  URLSession+ApiCredentials.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import Foundation

extension URLSession {
    /// Creates an URL session based on the default configuration, adding an HTTP Basic Authorization Header based on
    /// the credentials provided.
    convenience init(credentials: ApiCredentials?) {
        let configuration = URLSessionConfiguration.default
        
        if let credentials = credentials {
            configuration.httpAdditionalHeaders = ["Authorization": credentials.authorizationValue]
        }

        self.init(configuration: configuration)
    }
}
