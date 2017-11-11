//
//  DataSourceSection.swift
//  RemonderKit
//
//  Created by Steffen Ryll on 19.09.17.
//  Copyright © 2017 Remonder. All rights reserved.
//

public protocol DataSourceSection {
    associatedtype Row

    weak var delegate: DataSourceSectionDelegate? { get set }

    var numberOfRows: Int { get }

    subscript(rowAt _: Int) -> Row { get }
}
