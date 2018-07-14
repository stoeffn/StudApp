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

struct ApplePushNotification: Codable {
    enum CodingKeys: String, CodingKey {
        case alert
        case badgeNumber = "badge"
        case soundName = "sound"
        case isContentAvailable = "content-available"
        case categoryIdentifier = "category"
        case threadIdentifier = "thread-id"
    }

    let alert: Alert?
    let badgeNumber: Int?
    let soundName: String?
    let isContentAvailable: Int?
    let categoryIdentifier: String?
    let threadIdentifier: String?

    init(alert: Alert? = nil, badgeNumber: Int? = nil, soundName: String? = nil, isContentAvailable: Int? = nil,
         categoryIdentifier: String? = nil, threadIdentifier: String? = nil) {
        self.alert = alert
        self.badgeNumber = badgeNumber
        self.soundName = soundName
        self.isContentAvailable = isContentAvailable
        self.categoryIdentifier = categoryIdentifier
        self.threadIdentifier = threadIdentifier
    }
}

extension ApplePushNotification {
    struct Alert: Codable {
        enum CodingKeys: String, CodingKey {
            case titleKey = "title-loc-key"
            case titleArguments = "title-loc-args"
            case bodyKey = "loc-key"
            case bodyArguments = "loc-args"
        }

        let titleKey: String
        let titleArguments: [String]
        let bodyKey: String
        let bodyArguments: [String]

        init(titleKey: String, titleArguments: [String], bodyKey: String, bodyArguments: [String]) {
            self.titleKey = titleKey
            self.titleArguments = titleArguments
            self.bodyKey = bodyKey
            self.bodyArguments = bodyArguments
        }
    }
}
