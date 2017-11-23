//
//  DateFormatter+Shared.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.12.16.
//  Copyright © 2016 Julian Lobe & Steffen Ryll. All rights reserved.
//

/// A container for a lazy date formatter cache.
public struct SharedDateFormatters {
    public private(set) lazy var shortDate: DateFormatter = DateFormatter(dateStyle: .short)

    public private(set) lazy var shortTime: DateFormatter = DateFormatter(timeStyle: .short)

    public private(set) lazy var shortDateTime: DateFormatter = DateFormatter(dateStyle: .short, timeStyle: .short)

    public private(set) lazy var shortWeekday: DateFormatter = DateFormatter(format: "E")

    public private(set) lazy var mediumDate: DateFormatter = DateFormatter(dateStyle: .medium)

    public private(set) lazy var mediumTime: DateFormatter = DateFormatter(timeStyle: .medium)

    public private(set) lazy var mediumDateTime: DateFormatter = DateFormatter(dateStyle: .medium, timeStyle: .medium)

    public private(set) lazy var longDate: DateFormatter = DateFormatter(dateStyle: .long)

    public private(set) lazy var longTime: DateFormatter = DateFormatter(timeStyle: .long)

    public private(set) lazy var longDateTime: DateFormatter = DateFormatter(dateStyle: .long, timeStyle: .long)

    public private(set) lazy var weekday: DateFormatter = DateFormatter(format: "EEEE")

    public private(set) lazy var monthAndYear: DateFormatter = DateFormatter(format: "MMMM yyyy")
}

public extension DateFormatter {
    public static var shared = SharedDateFormatters()

    /// Creates a date formatter with a certain date and time style or a format string.
    convenience init(dateStyle: Style = .none, timeStyle: Style = .none, format: String? = nil) {
        self.init()
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
        dateFormat = format
    }
}
