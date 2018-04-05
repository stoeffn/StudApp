//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

@testable import StudKit

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

    static let event0 = EventResponse(id: "E0", startsAt: Date(timeIntervalSince1970: 1), endsAt: Date(timeIntervalSince1970: 2),
                                      isCanceled: true, cancellationReason: "Reason", location: "Location", summary: "Summary",
                                      category: "Category")
}
