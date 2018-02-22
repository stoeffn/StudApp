//
//  DataChange.swift
//  StudKit
//
//  Created by Steffen Ryll on 19.09.17.
//  Copyright © 2017 Remonder. All rights reserved.
//

public enum DataChange<Value, Index> {
    case insert
    case delete
    case update(Value)
    case move(to: Index)
}
