//
//  StoreStateTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 16.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class StoreStateTests: XCTestCase {
    private let encoder = ServiceContainer.default[JSONEncoder.self]
    private let decoder = ServiceContainer.default[JSONDecoder.self]

    // MARK: - Utilities

    // MARK: Is Unlocked

    func testIsUnlocked_deferred_false() {
        XCTAssertFalse(StoreService.State.deferred.isUnlocked)
    }

    func testIsUnlocked_locked_false() {
        XCTAssertFalse(StoreService.State.locked.isUnlocked)
    }

    func testIsUnlocked_unlocked_true() {
        XCTAssertTrue(StoreService.State.unlocked(validatedByServer: true).isUnlocked)
    }

    func testIsUnlocked_subscribed_true() {
        XCTAssertTrue(StoreService.State.subscribed(until: Date(), validatedByServer: true).isUnlocked)
    }

    // MARK: - Coding

    // MARK: Encoding

    func testEncode_deferred() {
        let state = StoreService.State.deferred
        let encodedState = try! encoder.encode(state)

        XCTAssertEqual(String(data: encodedState, encoding: .utf8), """
        {"state":"deferred"}
        """)
    }

    func testEncode_locked() {
        let state = StoreService.State.locked
        let encodedState = try! encoder.encode(state)

        XCTAssertEqual(String(data: encodedState, encoding: .utf8), """
        {"state":"locked"}
        """)
    }

    func testEncode_unlocked() {
        let state = StoreService.State.unlocked(validatedByServer: false)
        let encodedState = try! encoder.encode(state)

        XCTAssertEqual(String(data: encodedState, encoding: .utf8), """
        {"state":"unlocked"}
        """)
    }

    func testEncode_subscribed() {
        let state = StoreService.State.subscribed(until: Date(timeIntervalSince1970: 123), validatedByServer: false)
        let encodedState = try! encoder.encode(state)

        XCTAssertEqual(String(data: encodedState, encoding: .utf8), """
        {"state":"subscribed","subscribedUntil":123}
        """)
    }

    // MARK: Decoding

    func testDecode_deferred() {
        let encodedState = """
        {"state":"deferred"}
        """.data(using: .utf8)!
        let state = try! decoder.decode(StoreService.State.self, from: encodedState)

        guard case .deferred = state else { return XCTFail("Invalid state") }
    }

    func testDecode_locked() {
        let encodedState = """
        {"state":"locked"}
        """.data(using: .utf8)!
        let state = try! decoder.decode(StoreService.State.self, from: encodedState)

        guard case .locked = state else { return XCTFail("Invalid state") }
    }

    func testDecode_unlocked() {
        let encodedState = """
        {"state":"unlocked"}
        """.data(using: .utf8)!
        let state = try! decoder.decode(StoreService.State.self, from: encodedState)

        guard case .unlocked = state else { return XCTFail("Invalid state") }
        XCTAssertFalse(state.isVerifiedByServer ?? true)
    }

    func testDecode_subscribed() {
        let encodedState = """
        {"state":"subscribed","subscribedUntil":123}
        """.data(using: .utf8)!
        let state = try! decoder.decode(StoreService.State.self, from: encodedState)

        guard case let .subscribed(subscribedUntil, _) = state else { return XCTFail("Invalid state") }
        XCTAssertEqual(subscribedUntil, Date(timeIntervalSince1970: 123))
        XCTAssertFalse(state.isVerifiedByServer ?? true)
    }

    // MARK: - Persistence

    func testToAndFromDefaults() {
        StoreService.State.subscribed(until: Date(timeIntervalSince1970: 456), validatedByServer: true).toDefaults()
        let state = StoreService.State.fromDefaults

        XCTAssertNotNil(state)
        guard case let .subscribed(subscribedUntil, _)? = state else { return XCTFail("Invalid state") }
        XCTAssertEqual(subscribedUntil, Date(timeIntervalSince1970: 456))
        XCTAssertFalse(state?.isVerifiedByServer ?? true)
    }
}
