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

import MessageKit

public struct Message: Decodable, Equatable {
    var blubber_id: String
    var author: UserResponse
    var content: String
    var mkdate: String
}

extension Message: MessageType {
    public var sender: Sender {
        return Sender(id: author.id, displayName: author.givenName + " " + author.familyName)
    }

    public var messageId: String {
        return blubber_id
    }

    public var sentDate: Date {
        guard let timeInterval = TimeInterval(mkdate) else { return .distantPast }
        return Date(timeIntervalSince1970: timeInterval)
    }

    public var kind: MessageKind {
        return .text(content)
    }
}
