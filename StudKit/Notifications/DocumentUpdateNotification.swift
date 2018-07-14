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

struct DocumentUpdateNotification: Codable {
    enum CodingKeys: String, CodingKey {
        case notification = "aps"
        case documentId
        case documentTitle
        case ownerId
        case ownerFullname
        case courseId
        case courseTitle
    }

    let notification: ApplePushNotification
    let documentId: String
    let documentTitle: String
    let ownerId: String
    let ownerFullname: String
    let courseId: String
    let courseTitle: String

    init(notification: ApplePushNotification, documentId: String, documentTitle: String, ownerId: String, ownerFullname: String,
         courseId: String, courseTitle: String) {
        self.notification = notification
        self.documentId = documentId
        self.documentTitle = documentTitle
        self.ownerId = ownerId
        self.ownerFullname = ownerFullname
        self.courseId = courseId
        self.courseTitle = courseTitle
    }
}

extension DocumentUpdateNotification {
    static let template = DocumentUpdateNotification(
        notification: ApplePushNotification(
            alert: ApplePushNotification.Alert(
                titleKey: "Notifications.documentUpdateTitle",
                titleArguments: ["{{name}}"],
                bodyKey: "Notifications.documentUpdateBody",
                bodyArguments: [""]),
                threadIdentifier: "course-{{course_id}}-documents"),
        documentId: "{{id}}",
        documentTitle: "{{name}}",
        ownerId: "{{user_id}}",
        ownerFullname: "{{user_name}}",
        courseId: "{{course_id}}",
        courseTitle: "{{course_title}}")
}
