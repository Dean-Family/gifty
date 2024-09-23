//
//  EventTests.swift
//  GiftyTests
//
//  Created by Gavin Dean on 9/22/24.
//

import XCTest
@testable import Gifty
import SwiftData

@available(iOS 17, *)
final class EventTests: XCTestCase {
    
    func testEventCreation() {
        let event = Event(date: Date(), name: "Birthday")
        XCTAssertEqual(event.name, "Birthday")
        XCTAssertNotNil(event.date)
    }

    func testEventGiftRelationship() {
        let event = Event(date: Date(), name: "Birthday")
        let gift = Gift(name: "Sample Gift", cents: 1000)
        event.gifts = [gift]
        XCTAssertEqual(event.gifts?.count, 1)
        XCTAssertEqual(event.gifts?.first?.name, "Sample Gift")
    }
}
