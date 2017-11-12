//
//  DateFormatter+Shared.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.12.16.
//  Copyright © 2016 Julian Lobe & Steffen Ryll. All rights reserved.
//

/// A container for a lazy date formatter cache.
struct SharedDateFormatters {
    lazy var shortWeekday: DateFormatter = DateFormatter(format: "E")
    lazy var weekday: DateFormatter = DateFormatter(format: "EEEE")
    lazy var mediumDate: DateFormatter = DateFormatter(dateStyle: .medium)
    lazy var mediumDateTime: DateFormatter = DateFormatter(dateStyle: .medium, timeStyle: .medium)
    lazy var longDate: DateFormatter = DateFormatter(dateStyle: .long)
    lazy var shortTime: DateFormatter = DateFormatter(timeStyle: .short)
    lazy var monthAndYear: DateFormatter = DateFormatter(format: "MMMM yyyy")
}

extension DateFormatter {
    static var shared = SharedDateFormatters()

    /// Creates a date formatter with a certain date and time style or a format string.
    convenience init(dateStyle: Style = .none, timeStyle: Style = .none, format: String? = nil) {
        self.init()
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
        self.dateFormat = format
    }
}
