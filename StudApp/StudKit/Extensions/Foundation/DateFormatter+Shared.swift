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

public extension DateFormatter {
    public static let shortDate: DateFormatter = DateFormatter(dateStyle: .short)

    public static let shortTime: DateFormatter = DateFormatter(timeStyle: .short)

    public static let shortDateTime: DateFormatter = DateFormatter(dateStyle: .short, timeStyle: .short)

    public static let shortWeekday: DateFormatter = DateFormatter(format: "E")

    public static let mediumDate: DateFormatter = DateFormatter(dateStyle: .medium)

    public static let mediumTime: DateFormatter = DateFormatter(timeStyle: .medium)

    public static let mediumDateTime: DateFormatter = DateFormatter(dateStyle: .medium, timeStyle: .medium)

    public static let longDate: DateFormatter = DateFormatter(dateStyle: .long)

    public static let longTime: DateFormatter = DateFormatter(timeStyle: .long)

    public static let longDateTime: DateFormatter = DateFormatter(dateStyle: .long, timeStyle: .long)

    public static let weekday: DateFormatter = DateFormatter(format: "EEEE")

    public static let monthAndYear: DateFormatter = DateFormatter(format: "MMMM yyyy")

    /// Creates a date formatter with a certain date and time style or a format string.
    convenience init(dateStyle: Style = .none, timeStyle: Style = .none, format: String? = nil) {
        self.init()
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
        dateFormat = format
    }
}
