//
//  DataSource.swift
//  RemonderKit
//
//  Created by Steffen Ryll on 19.09.17.
//  Copyright © 2017 Remonder. All rights reserved.
//

public protocol DataSource {
    associatedtype Section
    associatedtype Row

    weak var delegate: DataSourceDelegate? { get set }

    var numberOfSections: Int { get }

    func numberOfRows(inSection index: Int) -> Int

    subscript (sectionAt index: Int) -> Section { get }

    subscript (rowAt indexPath: IndexPath) -> Row { get }
}
