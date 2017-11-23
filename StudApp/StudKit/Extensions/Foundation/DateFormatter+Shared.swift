//
//  DateFormatter+Shared.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.12.16.
//  Copyright © 2016 Steffen Ryll. All rights reserved.
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
