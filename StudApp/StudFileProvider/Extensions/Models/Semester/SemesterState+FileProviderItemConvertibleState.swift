//
//  SemesterState+FileProviderItemConvertibleState.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

extension SemesterState: FileProviderItemConvertibleState {
    public var item: FileProviderItemConvertible {
        return semester
    }
}
