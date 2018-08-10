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

/// `DelayOperation` is an `BaseOperation` that will simply wait for a given time interval, or until a specific `Date`.
///
/// It is important to note that this operation does **not** use the `sleep()` function, since that is inefficient and blocks
/// the thread on which it is called. Instead, this operation uses `DispatchQueue.after` to know when the appropriate amount of
/// time has passed.
///
/// If the interval is negative, or the `Date` is in the past, then this operation immediately finishes.
final class DelayOperation: BaseOperation {
    private let delay: Delays

    // MARK: - Delays

    private enum Delays {
        case interval(TimeInterval)
        case date(Date)

        var interval: TimeInterval {
            switch self {
            case let .interval(interval):
                return interval
            case let .date(date):
                return date.timeIntervalSinceNow
            }
        }
    }

    // MARK: - Life Cycle

    init(interval: TimeInterval) {
        delay = .interval(interval)
        super.init()
    }

    init(until date: Date) {
        delay = .date(date)
        super.init()
    }

    // MARK: - Executing and Cancelling

    override func execute() {
        let interval = delay.interval

        guard interval > 0 else { return finish() }

        DispatchQueue.global().asyncAfter(deadline: .now() + interval) {
            // If we were cancelled, then finish() has already been called.
            guard !self.isCancelled else { return }
            self.finish()
        }
    }

    override func cancel() {
        super.cancel()

        // Cancelling the operation means we don't want to wait anymore.
        finish()
    }
}
