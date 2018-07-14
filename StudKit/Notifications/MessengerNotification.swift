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
        case type
        case notification = "aps"
        case messageId
        case messageText
        case contextType
        case contextId
        case contextTitle
        case threadId
        case userId
        case userFullname
    }

    let type = NotificationTypes.blubberMessage
    let notification: ApplePushNotification
    let messageId: String
    let messageText: String
    let contextType: ContextTypes
    let contextId: String
    let contextTitle: String
    let threadId: String
    let userId: String
    let userFullname: String

    init(notification: ApplePushNotification, messageId: String, messageText: String, contextId: String, contextType: ContextTypes,
         contextTitle: String, threadId: String, userId: String, userFullname: String) {
        self.notification = notification
        self.messageId = messageId
        self.messageText = messageText
        self.contextType = contextType
        self.contextId = contextId
        self.contextTitle = contextTitle
        self.threadId = threadId
        self.userId = userId
        self.userFullname = userFullname
    }
}

extension MessengerNotification {
    enum ContextTypes: String, Codable {
        case course
        case `private`
        case `public`
        case template = "{{context_type}}"
    }
}

extension MessengerNotification {
    static let template = MessengerNotification(
        notification: ApplePushNotification(
            alert: ApplePushNotification.Alert(
                titleKey: "Notifications.messageTitle",
                titleArguments: ["{{context_name}}"],
                bodyKey: "Notifications.messageBody",
                bodyArguments: ["{{user_name}}", "{{content}}"]),
            threadIdentifier: "{{context_id}}-messages"),
        messageId: "{{id}}",
        messageText: "{{content}}",
        contextId: "{{context_id}}",
        contextType: ContextTypes.template,
        contextTitle: "{{context_title}}",
        threadId: "{{thread_id}}",
        userId: "{{user_id}}",
        userFullname: "{{user_name}}")
}

