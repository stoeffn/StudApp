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

    // MARK: - Data

    private let thanksNotes: [ThanksNote] = [
        (title: "Julian Lobe", description: "Beta-Tester, QA-Man, and Friend", url: nil),
        (title: "Cornelius Kater", description: "Support and Communication", url: URL(string: "http://ckater.de/")),
        (title: "Stud.IP e.V.", description: "Development of APIs", url: URL(string: "http://studip.de/")),
        (title: "icons8", description: "Glyphs", url: URL(string: "https://icons8.com/")),
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
