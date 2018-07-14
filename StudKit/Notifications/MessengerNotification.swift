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

public struct MessengerNotification: Codable {
    public enum CodingKeys: String, CodingKey {
        case notification = "aps"
        case messageId
        case messageText
        case threadId
        case threadTitle
        case userId
        case userFullname
    }

    let notification: ApplePushNotification
    let messageId: String
    let messageText: String
    let threadId: String
    let threadTitle: String
    let userId: String
    let userFullname: String


    init(notification: ApplePushNotification, messageId: String, messageText: String, threadId: String, threadTitle: String,
         userId: String, userFullname: String) {
        self.notification = notification
        self.messageId = messageId
        self.messageText = messageText
        self.threadId = threadId
        self.threadTitle = threadTitle
        self.userId = userId
        self.userFullname = userFullname
    }
}

extension MessengerNotification {
    static let template = MessengerNotification(
        notification: ApplePushNotification(
            alert: ApplePushNotification.Alert(
                titleKey: "Notifications.messageTitle",
                titleArguments: ["{{von_name}}"],
                bodyKey: "Notifications.messageBody",
                bodyArguments: ["{{nachricht}}"]),
            threadIdentifier: "{{thread_id}}-messages"),
        messageId: "{{blubber_id}}",
        messageText: "{{nachricht}}",
        threadId: "{{thread_id}}",
        threadTitle: "Thread Title",
        userId: "{{von_id}}",
        userFullname: "{{von_name}}")
}

