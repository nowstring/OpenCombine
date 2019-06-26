//
//  SinkTests.swift
//  
//
//  Created by Sergej Jaskiewicz on 16.06.2019.
//

import XCTest

#if OPENCOMBINE_COMPATIBILITY_TEST
import Combine
#else
import OpenCombine
#endif

@available(macOS 10.15, *)
final class SinkTests: XCTestCase {

    static let allTests = [
        ("testDescription", testDescription),
        ("testReflection", testReflection),
        ("testSubscription", testSubscription),
        ("testReceiveValue", testReceiveValue),
        ("testPublisherOperator", testPublisherOperator),
    ]

    private typealias Sut = Subscribers.Sink<PassthroughSubject<Int, Never>>

    func testDescription() {
        let sink = Sut(receiveValue: { _ in })

        XCTAssertEqual(sink.description, "Sink")
        XCTAssertEqual(sink.playgroundDescription as? String, "Sink")
    }

    func testReflection() {
        let sink = Sut(receiveValue: { _ in })
        XCTAssert(sink.customMirror.children.isEmpty)
    }

    func testSubscription() {

        let sink = Sut(receiveValue: { _ in })

        let subscription1 = CustomSubscription()
        sink.receive(subscription: subscription1)
        XCTAssertEqual(subscription1.lastRequested, .unlimited)
        XCTAssertFalse(subscription1.canceled)

        let subscription2 = CustomSubscription()
        sink.receive(subscription: subscription2)
        XCTAssertFalse(subscription1.canceled)
        XCTAssertTrue(subscription2.canceled)

        sink.receive(subscription: subscription1)
        XCTAssertTrue(subscription1.canceled)

        subscription1.canceled = false
        sink.receive(completion: .finished)
        XCTAssertFalse(subscription1.canceled)
    }

    func testReceiveValue() {

        var value = 0
        var completion: Subscribers.Completion<Never>?

        let sink = Sut(receiveCompletion: { completion = $0 },
                       receiveValue: { value = $0 })

        let publisher = PassthroughSubject<Int, Never>()

        XCTAssertEqual(sink.receive(12), .none)
        XCTAssertEqual(value, 12)
        XCTAssertNil(completion)

        publisher.subscribe(sink)
        publisher.send(42)
        XCTAssertEqual(value, 42)
        XCTAssertNil(completion)

        publisher.send(completion: .finished)
        XCTAssertEqual(value, 42)
        XCTAssertNotNil(completion)

        XCTAssertEqual(sink.receive(100), .none)
        XCTAssertEqual(value, 100)

        publisher.subscribe(sink)
        publisher.send(1000000)
        XCTAssertEqual(value, 100)

        sink.cancel()
        publisher.send(-1)
        XCTAssertEqual(value, 100)
    }

    func testPublisherOperator() {
        var value = 0
        let publisher = PassthroughSubject<Int, Never>()

        let sink = publisher.sink(receiveValue: { value = $0 })
        XCTAssertEqual(value, 0)

        publisher.send(42)
        XCTAssertEqual(value, 42)

        sink.cancel()
        publisher.send(1)
        XCTAssertEqual(value, 42)

        do {
            _ = publisher.sink(receiveValue: { value = $0 })
        }

        publisher.send(100)
        XCTAssertEqual(value, 100)
    }
}