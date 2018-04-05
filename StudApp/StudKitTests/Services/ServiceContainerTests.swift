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

import StudKit
import XCTest

protocol TestProtocol {}

final class ServiceContainerTests: XCTestCase {
    private final class TestClass: TestProtocol {}

    private final class GenericTestClass<Value>: TestProtocol {}

    private struct TestStruct: TestProtocol {
        let id: String
    }

    private final class TestProvider: ServiceProvider {
        func registerServices(in container: ServiceContainer) {
            container[String.self] = "123"
        }
    }

    // MARK: - Subscripting

    func testSubscript_class_class() {
        let container = ServiceContainer()
        let test = TestClass()
        container[TestClass.self] = test

        XCTAssertTrue(container[TestClass.self] === test)
    }

    func testSubscript_genericClass_genericClass() {
        let container = ServiceContainer()
        let test = GenericTestClass<String>()
        container[GenericTestClass<String>.self] = test

        XCTAssertTrue(container[GenericTestClass<String>.self] === test)
    }

    func testSubscript_protocol_class() {
        let container = ServiceContainer()
        let test = TestClass()
        container[TestProtocol.self] = test

        XCTAssertTrue(container[TestProtocol.self] as! TestClass === test)
    }

    func testSubscript_protocol_struct() {
        let container = ServiceContainer()
        let test = TestStruct(id: "abc")
        container[TestProtocol.self] = test

        XCTAssertTrue((container[TestProtocol.self] as! TestStruct).id == test.id)
    }

    // MARK: - Providing Services

    func testInit_provider_string() {
        let container = ServiceContainer(providers: TestProvider())

        XCTAssertEqual(container[String.self], "123")
    }

    func testRegister_provider_string() {
        let container = ServiceContainer()
        container.register(providers: [TestProvider()])

        XCTAssertEqual(container[String.self], "123")
    }
}
