//
//  StudApp—Stud.IP to Go
//  Copyright © 2019, Steffen Ryll
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

public final class InMemoryLog {
    var logItems: [(date: Date, file: StaticString, line: UInt, message: String)] = []

    public var isActive = false {
        didSet {
            guard !isActive else { return }
            logItems.removeAll()
        }
    }

    public func log(_ message: String, file: StaticString = #file, line: UInt = #line) {
        guard isActive else { return }
        logItems.append((date: Date(), file: file, line: line, message: message))
    }

    public func log(_ error: Error, file: StaticString = #file, line: UInt = #line) {
        guard isActive else { return }
        let message = "\(String(describing: error))—\(error.localizedDescription)"
        logItems.append((date: Date(), file: file, line: line, message: message))
    }

    public var formattedLog: String {
        return logItems
            .map { "[\($0.date) @ \($0.file):\($0.line)]: \($0.message)" }
            .joined(separator: "\n")
    }

    public static let shared = InMemoryLog()
}
