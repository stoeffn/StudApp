//
//  ServiceContainerTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 24.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
import StudKit

protocol TestProtocol { }

final class ServiceContainerTests : XCTestCase {
    final class TestClass : TestProtocol { }

    final class GenericTestClass<Value> : TestProtocol { }

    struct TestStruct : TestProtocol {
        let id: String
    }

    final class TestProvider : ServiceProvider {
        func registerServices(in container: ServiceContainer) {
            container[String.self] = "123"
        }
    }
    
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

    func testInit_provider_string() {
        let container = ServiceContainer(providers: TestProvider())

        XCTAssertEqual(container[String.self], "123")
    }

    func testRegister_provider_string() {
        let container = ServiceContainer()
        container.register(providers: TestProvider())

        XCTAssertEqual(container[String.self], "123")
    }
}
