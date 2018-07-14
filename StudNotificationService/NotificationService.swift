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

import StudKit
import UserNotifications

final class NotificationService: UNNotificationServiceExtension {
    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var content: UNNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        self.content = request.content

        guard let content = augmentedNotification(for: request.content) else { return self.content = nil }
        contentHandler(content)
    }

    func augmentedNotification(for content: UNNotificationContent) -> UNNotificationContent? {
        guard let type = content.userInfo["type"] as? String else { return content }

        switch NotificationTypes(rawValue: type) {
        case .documentUpdate?:
            return augmentedDocumentUpdateNotification(for: content)
        case .blubberMessage?:
            return augmentedBlubberMessageNotification(for: content)
        case nil:
            return content
        }
    }

    func augmentedDocumentUpdateNotification(for content: UNNotificationContent) -> UNNotificationContent? {
        guard let mutableContent = content.mutableCopy() as? UNMutableNotificationContent else { return content }
        let ownerFullname = content.userInfo[DocumentUpdateNotification.CodingKeys.ownerFullname.rawValue] as? String

        guard #available(iOSApplicationExtension 12.0, *) else { return mutableContent }

        mutableContent.summaryArgumentCount = 1
        mutableContent.summaryArgument = ownerFullname ?? content.summaryArgument

        return mutableContent
    }

    func augmentedBlubberMessageNotification(for content: UNNotificationContent) -> UNNotificationContent? {
        guard let mutableContent = content.mutableCopy() as? UNMutableNotificationContent else { return content }
        let change = content.userInfo[MessengerNotification.CodingKeys.changeType.rawValue] as? String
        let userFullname = content.userInfo[MessengerNotification.CodingKeys.userFullname.rawValue] as? String
        let text = content.userInfo[MessengerNotification.CodingKeys.messageText.rawValue] as? String

        guard change != MessengerNotification.ChangeTypes.deleted.rawValue else { return nil }

        mutableContent.subtitle = userFullname ?? mutableContent.subtitle
        mutableContent.body = text ?? mutableContent.body

        guard #available(iOSApplicationExtension 12.0, *) else { return mutableContent }

        mutableContent.summaryArgumentCount = 1
        mutableContent.summaryArgument = userFullname ?? content.summaryArgument

        return mutableContent
    }

    override func serviceExtensionTimeWillExpire() {
        guard let content = content else { return }
        contentHandler?(content)
    }
}
