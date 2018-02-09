//
//  EventResponseTests+Data.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 26.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

extension EventResponseTests {
    static let eventData = """
        {
            "event_id": "0",
            "start": "1478187000",
            "end": "1478192400",
            "title": "Thu , 03.11.2016 16:30 - 18:00",
            "description": "Sümmary",
            "categories": "Sitzung",
            "room": "(Raum 023: Multimedia-Hörsaal,  Gebaeude 3703: Technische Informatik)",
            "deleted": null,
            "canceled": false
        }
    """.data(using: .utf8)!

    static let canceledEventData = """
        {
            "event_id": "1",
            "start": "1486131300",
            "end": "1486136700",
            "title": "Fri , 03.02.2017 15:15 - 16:45",
            "description": "",
            "categories": "Sitzung",
            "room": "(cancelled)",
            "deleted": true,
            "canceled": false
        }
    """.data(using: .utf8)!

    static let canceledEventWithReasonData = """
        {
            "event_id": "2",
            "start": "1483630200",
            "end": "1483635600",
            "title": "Thu , 05.01.2017 16:30 - 18:00",
            "description": "",
            "categories": "Sitzung",
            "room": "(Weihnachtsferien 2016)",
            "deleted": true,
            "canceled": "Weihnachtsferien 2016"
        }
    """.data(using: .utf8)!
}
