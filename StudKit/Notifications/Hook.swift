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

public struct Hook: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "hook_id"
        case title = "name"
        case isActive = "activated"
        case isImportant = "cronjob"
        case ifType = "if_type"
        case isEditable = "editable"
        case thenType = "then_type"
        case thenSettings = "then_settings"
    }

    let id: String
    let title: String
    let isActive: Bool
    let isEditable: Bool
    let isImportant: Bool
    let ifType: IfTypes
    let thenType: ThenTypes
    let thenSettings: ThenSettings

    init(id: String, title: String, isActive: Bool = true, isEditable: Bool = false, isImportant: Bool = false, ifType: IfTypes,
         thenType: ThenTypes, thenSettings: ThenSettings) {
        self.id = id
        self.title = title
        self.isActive = isActive
        self.isEditable = isEditable
        self.isImportant = isImportant
        self.ifType = ifType
        self.thenType = thenType
        self.thenSettings = thenSettings
    }
}

extension Hook {
    enum IfTypes: String, Codable {
        case documentChange = "IfFilerefHook"
    }
}

extension Hook {
    enum ThenTypes: String, Codable {
        case socketHook = "ThenSocketHook"
    }
}

extension Hook {
    struct ThenSettings: Codable {
        enum CodingKeys: String, CodingKey {
            case url = "webhook_url"
            case json
        }

        let url: URL
        let json: String

        init(url: URL, json: String) {
            self.url = url
            self.json = json
        }
    }
}
