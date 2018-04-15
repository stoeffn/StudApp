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

public final class ColorPickerViewModel<Color>: DataSourceSection {
    public typealias ColorAndTitle = (color: Color, title: String)
    public typealias Row = (key: Int, value: ColorAndTitle)

    private let colors: [Row]
    private var completion: (Row) -> Void

    public init(colors: [Row], completion: @escaping (Row) -> Void) {
        self.colors = colors
        self.completion = completion
    }

    public convenience init(colors: [Int: ColorAndTitle], completion: @escaping (Row) -> Void) {
        let colors = colors.enumerated()
            .sorted { $0.element.key < $1.element.key }
            .map { $1 }
        self.init(colors: colors, completion: completion)
    }

    public var numberOfRows: Int {
        return colors.count
    }

    public subscript(rowAt index: Int) -> Row {
        return colors[index]
    }

    public func didSelectColor(atIndex index: Int) {
        completion(colors[index])
    }
}
