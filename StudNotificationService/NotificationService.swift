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
    private var content: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        content = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let content = content else { return }

        let ownerFullname = content.userInfo[DocumentUpdateNotification.CodingKeys.ownerFullname.rawValue] as? String
        content.summaryArgumentCount = 1
        content.summaryArgument = ownerFullname ?? content.summaryArgument

        contentHandler(content)
    }

    override func serviceExtensionTimeWillExpire() {
        guard let contentHandler = contentHandler, let content = content else { return }
        contentHandler(content)
    }
}
