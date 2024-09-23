//
//  GifteeTests.swift
//  GiftyTests
//
//  Created by Gavin Dean on 9/22/24.
//

import XCTest
@testable import Gifty
import SwiftData

@available(iOS 17, *)
final class GifteeTests: XCTestCase {
    
    func testGifteeCreation() {
        let giftee = Giftee(firstname: "John", lastname: "Doe")
        XCTAssertEqual(giftee.firstname, "John")
        XCTAssertEqual(giftee.lastname, "Doe")
    }

    func testGifteeGiftRelationship() {
        let giftee = Giftee(firstname: "John", lastname: "Doe")
        let gift = Gift(name: "Sample Gift", cents: 1000)
        giftee.gifts = [gift]
        XCTAssertEqual(giftee.gifts?.count, 1)
        XCTAssertEqual(giftee.gifts?.first?.name, "Sample Gift")
    }
}
