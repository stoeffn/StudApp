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
        XCTAssertTrue(StoreService.State.unlocked(verifiedByServer: true).isUnlocked)
    }

    func testIsUnlocked_subscribed_true() {
        XCTAssertTrue(StoreService.State.subscribed(until: Date(), verifiedByServer: true).isUnlocked)
    }

    // MARK: - Coding

    // MARK: Encoding

    func testEncode_deferred() {
        let state = StoreService.State.deferred
        let encodedState = try! encoder.encode(state)

        XCTAssertEqual(String(data: encodedState, encoding: .utf8), """
        {"state":"DEFERRED"}
        """)
    }

    func testEncode_locked() {
        let state = StoreService.State.locked
        let encodedState = try! encoder.encode(state)

        XCTAssertEqual(String(data: encodedState, encoding: .utf8), """
        {"state":"LOCKED"}
        """)
    }

    func testEncode_unlocked() {
        let state = StoreService.State.unlocked(verifiedByServer: false)
        let encodedState = try! encoder.encode(state)

        XCTAssertEqual(String(data: encodedState, encoding: .utf8), """
        {"state":"UNLOCKED"}
        """)
    }

    func testEncode_subscribed() {
        let state = StoreService.State.subscribed(until: Date(timeIntervalSince1970: 123), verifiedByServer: false)
        let encodedState = try! encoder.encode(state)

        XCTAssertEqual(String(data: encodedState, encoding: .utf8), """
        {"state":"SUBSCRIBED","subscribedUntil":123}
        """)
    }

    // MARK: Decoding

    func testDecode_deferred() {
        let encodedState = """
        {"state":"DEFERRED"}
        """.data(using: .utf8)!
        let state = try! decoder.decode(StoreService.State.self, from: encodedState)

        guard case .deferred = state else { return XCTFail("Invalid state") }
        XCTAssertFalse(state.isVerifiedByServer)
    }

    func testDecode_locked() {
        let encodedState = """
        {"state":"LOCKED"}
        """.data(using: .utf8)!
        let state = try! decoder.decode(StoreService.State.self, from: encodedState)

        guard case .locked = state else { return XCTFail("Invalid state") }
        XCTAssertFalse(state.isVerifiedByServer)
    }

    func testDecode_unlocked() {
        let encodedState = """
        {"state":"unlocked"}
        """.data(using: .utf8)!
        let state = try! decoder.decode(StoreService.State.self, from: encodedState)

        guard case .unlocked = state else { return XCTFail("Invalid state") }
        XCTAssertFalse(state.isVerifiedByServer)
    }

    func testDecode_subscribed() {
        let timestamp = Date() + 123
        let encodedState = """
        {"state":"subscribed","subscribedUntil":\(timestamp.timeIntervalSince1970)}
        """.data(using: .utf8)!
        let state = try! decoder.decode(StoreService.State.self, from: encodedState)

        guard case let .subscribed(subscribedUntil, _) = state else { return XCTFail("Invalid state") }
        XCTAssertTrue(subscribedUntil.timeIntervalSince1970 - timestamp.timeIntervalSince1970 < 0.001)
        XCTAssertFalse(state.isVerifiedByServer)
    }

    func testDecode_subscribedExpired() {
        let encodedState = """
        {"state":"subscribed","subscribedUntil":123}
        """.data(using: .utf8)!
        let state = try! decoder.decode(StoreService.State.self, from: encodedState)

        guard case .locked = state else { return XCTFail("Invalid state") }
    }

    // MARK: - Persistence

    func testToAndFromDefaults() {
        let timestamp = Date() + 123
        StoreService.State.subscribed(until: timestamp, verifiedByServer: true).toDefaults()
        let state = StoreService.State.fromDefaults

        XCTAssertNotNil(state)
        guard case let .subscribed(subscribedUntil, _)? = state else { return XCTFail("Invalid state") }
        XCTAssertTrue(subscribedUntil.timeIntervalSince1970 - timestamp.timeIntervalSince1970 < 0.001)
        XCTAssertFalse(state?.isVerifiedByServer ?? true)
    }
}
