//
//  AboutViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 28.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public typealias ThanksNote = (title: String, description: String, url: URL?)

public final class AboutViewModel {
    // MARK: - Life Cycle

    public init() {}

    // MARK: - Thanks Data

    private let thanksNotes: [ThanksNote] = [
        (title: "Julian Lobe", description: "QA-Man", url: nil),
        (title: "Cornelius Kater", description: "Stud.IP Support", url: nil),
        (title: "icons8", description: "Icons and Glyphs", url: URL(string: "https://icons8.com/")),
    ]
}

extension AboutViewModel: DataSourceSection {
    public typealias Row = ThanksNote

    public var numberOfRows: Int {
        return thanksNotes.count
    }

    public subscript(rowAt index: Int) -> ThanksNote {
        return thanksNotes[index]
    }
}
