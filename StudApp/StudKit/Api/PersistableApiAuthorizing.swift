//
//  PersistableApiAuthorizing.swift
//  StudKit
//
//  Created by Steffen Ryll on 08.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

protocol PersistableApiAuthorizing: ApiAuthorizing {
    init(fromPersistedService service: String) throws

    var service: String { get }

    func persistCredentials() throws

    func removeCredentials() throws
}
